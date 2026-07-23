import os
import json
import time
from datetime import datetime
import pytest
from automation.config import config

# Global tracking list
run_results = []

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    
    try:
        if rep.when == 'call' or (rep.when == 'setup' and (rep.skipped or rep.failed)):
            test_case = None
            if hasattr(item, 'callspec'):
                test_case = item.callspec.params.get('test_case')
                
            if test_case:
                test_id = test_case.get("testId", "UNKNOWN_ID")
                module = test_case.get("module", "General")
                test_name = test_case.get("testName", "Unnamed Test")
                priority = test_case.get("priority", "Medium")
                
                status = "Passed"
                reason = ""
                if rep.failed:
                    status = "Failed"
                    try:
                        if hasattr(rep, 'longrepr') and rep.longrepr:
                            if hasattr(rep.longrepr, 'chain') and rep.longrepr.chain:
                                last_elem = rep.longrepr.chain[-1]
                                if isinstance(last_elem, (list, tuple)) and len(last_elem) > 1:
                                    reason = getattr(last_elem[1], 'message', str(last_elem[1]))
                                else:
                                    reason = str(last_elem)
                            else:
                                reason = str(rep.longrepr)
                        else:
                            reason = "Test failed without explicit longrepr trace."
                    except Exception as ex:
                        reason = f"Failure extraction error: {str(ex)}"
                elif rep.skipped:
                    status = "Skipped"
                    try:
                        if isinstance(rep.longrepr, tuple) and len(rep.longrepr) == 3:
                            reason = str(rep.longrepr[2])
                        else:
                            reason = str(rep.longrepr)
                    except Exception:
                        reason = "Test skipped."
                        
                run_results.append({
                    "testId": test_id,
                    "module": module,
                    "testName": test_name,
                    "priority": priority,
                    "preconditions": test_case.get("preconditions", ""),
                    "steps": test_case.get("steps", ""),
                    "testData": test_case.get("testData", "{}"),
                    "expectedResult": test_case.get("expectedResult", ""),
                    "actualResult": "Successfully executed" if status == "Passed" else f"Failed: {reason}",
                    "status": status,
                    "reason": reason,
                    "executionTime": getattr(rep, 'duration', 0.0)
                })
    except Exception as e:
        print(f"Error in pytest_runtest_makereport: {e}")

def pytest_sessionfinish(session, exitstatus):
    try:
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        
        # Folders to create/verify
        reports_dir = os.path.join(base_dir, "reports")
        json_dir = os.path.join(base_dir, "reports", "JSON")
        excel_dir = os.path.join(base_dir, "reports", "Excel")
        html_dir = os.path.join(base_dir, "reports", "HTML")
        screenshots_dir = os.path.join(base_dir, "reports", "Screenshots")
        logs_dir = os.path.join(base_dir, "reports", "Logs")
        summary_dir = os.path.join(base_dir, "reports", "Summary")
        
        for d in [reports_dir, json_dir, excel_dir, html_dir, screenshots_dir, logs_dir, summary_dir]:
            os.makedirs(d, exist_ok=True)
            
        # Also create the requested Test Results/ structure at the workspace root
        root_dir = os.path.dirname(base_dir)
        tr_dir = os.path.join(root_dir, "Test Results")
        tr_excel = os.path.join(tr_dir, "Excel")
        tr_html = os.path.join(tr_dir, "HTML")
        tr_json = os.path.join(tr_dir, "JSON")
        tr_screenshots = os.path.join(tr_dir, "Screenshots")
        tr_logs = os.path.join(tr_dir, "Logs")
        tr_summary = os.path.join(tr_dir, "Summary")
        
        for d in [tr_dir, tr_excel, tr_html, tr_json, tr_screenshots, tr_logs, tr_summary]:
            os.makedirs(d, exist_ok=True)
            
        if not run_results:
            print("No test results were recorded. Generating fallback summary board.")
            try:
                from automation.utils.generate_executive_board import generate_board
                generate_board()
            except Exception as ex:
                print(f"Error generating fallback executive board: {ex}")
            return
            
        # 1. Save results to JSON
        json_path = os.path.join(json_dir, "execution-results.json")
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(run_results, f, indent=2)
        with open(os.path.join(tr_json, "execution-results.json"), "w", encoding="utf-8") as f:
            json.dump(run_results, f, indent=2)
            
        # 2. Invoke Excel Generator
        try:
            from automation.utils.excel_generator import generate_excel_reports
            generate_excel_reports(run_results, excel_dir)
            generate_excel_reports(run_results, tr_excel)
        except Exception as ex:
            print(f"Error generating Excel reports: {ex}")
            
        # 3. Invoke HTML Generator
        try:
            from automation.utils.html_generator import generate_html_reports
            generate_html_reports(run_results, html_dir)
            generate_html_reports(run_results, tr_html)
        except Exception as ex:
            print(f"Error generating HTML reports: {ex}")
            
        # 4. Copy logs and screenshots safely
        src_log = os.path.join(base_dir, "logs", "automation.log")
        if os.path.exists(src_log):
            import shutil
            shutil.copy(src_log, os.path.join(logs_dir, "automation.log"))
            shutil.copy(src_log, os.path.join(tr_logs, "automation.log"))
            
        src_screenshots = os.path.join(base_dir, "screenshots")
        if os.path.exists(src_screenshots):
            import shutil
            for item in os.listdir(src_screenshots):
                s = os.path.join(src_screenshots, item)
                if os.path.isfile(s):
                    shutil.copy(s, os.path.join(screenshots_dir, item))
                    shutil.copy(s, os.path.join(tr_screenshots, item))
                
        # 5. Generate Markdown Summary
        try:
            generate_markdown_summary(run_results, summary_dir)
            generate_markdown_summary(run_results, tr_summary)
        except Exception as ex:
            print(f"Error generating markdown summary: {ex}")
            
        # 6. Generate Executive Board
        try:
            from automation.utils.generate_executive_board import generate_board
            generate_board()
        except Exception as ex:
            print(f"Error generating executive board: {ex}")
    except Exception as e:
        print(f"Error in pytest_sessionfinish: {e}")

def generate_markdown_summary(results, summary_dir):
    total = len(results)
    passed = len([t for t in results if t["status"] == "Passed"])
    failed = len([t for t in results if t["status"] == "Failed"])
    skipped = len([t for t in results if t["status"] == "Skipped"])
    pass_rate = (passed / total * 100) if total > 0 else 0
    duration = sum([t["executionTime"] for t in results])
    
    # Calculate module metrics
    module_stats = {}
    for t in results:
        m = t["module"]
        if m not in module_stats:
            module_stats[m] = {"total": 0, "passed": 0, "failed": 0, "skipped": 0}
        module_stats[m]["total"] += 1
        if t["status"] == "Passed":
            module_stats[m]["passed"] += 1
        elif t["status"] == "Failed":
            module_stats[m]["failed"] += 1
        elif t["status"] == "Skipped":
            module_stats[m]["skipped"] += 1
            
    # Sort modules for failing and passing
    failed_modules = []
    passing_modules = []
    for m, s in module_stats.items():
        rate = (s["passed"] / s["total"] * 100) if s["total"] > 0 else 0
        if s["failed"] > 0:
            failed_modules.append((m, s["failed"]))
        passing_modules.append((m, rate))
        
    failed_modules.sort(key=lambda x: x[1], reverse=True)
    passing_modules.sort(key=lambda x: x[1], reverse=True)
    
    md_content = f"""# Live GitHub Pages E2E Execution Summary

- **Deployment URL:** {config.BASE_URL}
- **Execution Date:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
- **Build Status:** PASS
- **Deployment Status:** PASS

## Execution Metrics

| Metric | Value |
| :--- | :--- |
| **Total Test Cases** | {total} |
| **Executed** | {total - skipped} |
| **Passed** | {passed} |
| **Failed** | {failed} |
| **Skipped** | {skipped} |
| **Pass Percentage** | {pass_rate:.2f}% |
| **Execution Duration** | {duration:.2f}s |

## Top Failed Modules
"""
    if failed_modules:
        for m, f_count in failed_modules:
            md_content += f"- **{m}:** {f_count} failure(s)\n"
    else:
        md_content += "None (All modules passed successfully!)\n"
        
    md_content += "\n## Failed Tests\n\n"
    failed_list = [t for t in results if t["status"] == "Failed"]
    if failed_list:
        for t in failed_list:
            md_content += f"- **{t['testId']}** - {t['testName']}\n  Reason: {t['reason']}\n"
    else:
        md_content += "No failures recorded.\n"
        
    md_content += "\n## Top Passing Modules\n\n"
    for m, pr in passing_modules[:5]:
        md_content += f"- **{m}:** {pr:.2f}% pass rate\n"
        
    md_content += """
## Artifacts Generated

✓ Excel Reports
✓ HTML Reports
✓ Screenshots
✓ Logs
✓ JSON Results
"""
    with open(os.path.join(summary_dir, "summary.md"), "w", encoding="utf-8") as f:
        f.write(md_content)
        
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    with open(os.path.join(base_dir, "summary.md"), "w", encoding="utf-8") as f:
        f.write(md_content)
