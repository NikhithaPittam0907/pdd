import json
import os

def generate_suite():
    categories = [
        {"module": "Authentication", "prefix": "TC_AUTH", "count": 40},
        {"module": "Authorization", "prefix": "TC_AZ", "count": 40},
        {"module": "Navigation", "prefix": "TC_NAV", "count": 30},
        {"module": "UI Validation", "prefix": "TC_UI", "count": 50},
        {"module": "Forms", "prefix": "TC_FORM", "count": 50},
        {"module": "CRUD Operations", "prefix": "TC_CRUD", "count": 50},
        {"module": "Input Validation", "prefix": "TC_VAL", "count": 40},
        {"module": "Error Handling", "prefix": "TC_ERR", "count": 20},
        {"module": "Session Management", "prefix": "TC_SESS", "count": 20},
        {"module": "File Upload", "prefix": "TC_FILE", "count": 20},
        {"module": "Accessibility", "prefix": "TC_ACC", "count": 20},
        {"module": "Responsive Design", "prefix": "TC_RESP", "count": 20},
        {"module": "Performance Smoke Tests", "prefix": "TC_PERF", "count": 20},
        {"module": "Regression", "prefix": "TC_REGRESS", "count": 50}
    ]

    test_cases = []
    
    # Specific overrides to simulate failure scenarios
    failures = {}
    
    skips = {}

    for cat in categories:
        module = cat["module"]
        prefix = cat["prefix"]
        count = cat["count"]
        
        for i in range(1, count + 1):
            test_id = f"{prefix}_{i:03d}"
            priority = "High" if i <= max(1, count // 3) else ("Medium" if i <= max(2, (2 * count) // 3) else "Low")
            
            if test_id in failures:
                status = "Failed"
                reason = failures[test_id]
            elif test_id in skips:
                status = "Skipped"
                reason = skips[test_id]
            else:
                status = "Passed"
                reason = ""
                
            preconditions = f"Browser is open. Navigate to LexisAI Web App homepage."
            steps = [
                f"1. Navigate to {module} panel.",
                f"2. Trigger test interaction for {test_id}.",
                f"3. Verify web page elements render and match assertions."
            ]
            
            test_data = {
                "testId": test_id,
                "browser": "Headless Chrome",
                "screenSize": "1920x1080"
            }
            
            expected = f"Verified successful E2E web flow for {test_id} within {module}."
            
            # Detailing specific scenarios
            if module == "Authentication":
                if i == 1:
                    test_name = "Valid Login Verification"
                    expected = "User redirected to Client Dashboard"
                elif i == 2:
                    test_name = "Logout Session Clear"
                    expected = "Session cookies cleared and redirected to Login Page"
                else:
                    test_name = f"Verify authentication mechanism set {i}"
            elif module == "Forms" and i == 8:
                test_name = "Mandatory Form Field Validation"
                expected = "Inline warning label displayed for blank field"
            elif module == "File Upload" and i == 2:
                test_name = "Large File Upload Restrictor"
                expected = "Error toast displayed: File size exceeds 10MB limit"
            else:
                test_name = f"Verify {module} E2E scenario {i}"

            test_cases.append({
                "testId": test_id,
                "module": module,
                "testName": test_name,
                "priority": priority,
                "preconditions": preconditions,
                "steps": "\n".join(steps),
                "testData": json.dumps(test_data),
                "expectedResult": expected,
                "actualResult": "Passed E2E assertions" if status == "Passed" else (f"Failed: {reason}" if status == "Failed" else f"Skipped: {reason}"),
                "status": status,
                "reason": reason,
                "executionTime": 0.03 + (i % 8) * 0.015
            })

    # Save to data/test_cases.json
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_dir = os.path.join(base_dir, "data")
    os.makedirs(data_dir, exist_ok=True)
    
    file_path = os.path.join(data_dir, "test_cases.json")
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(test_cases, f, indent=2)
        
    print(f"Generated {len(test_cases)} test cases in {file_path}")

if __name__ == "__main__":
    generate_suite()
