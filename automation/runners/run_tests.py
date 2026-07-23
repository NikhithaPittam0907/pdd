import os
import sys
import argparse
import subprocess

# Auto-install essential dependencies
required_packages = ["pytest", "Appium-Python-Client", "selenium", "openpyxl"]
for pkg in required_packages:
    try:
        if pkg == "Appium-Python-Client":
            import appium
        else:
            __import__(pkg)
    except ImportError:
        print(f"Package '{pkg}' not found. Installing...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", pkg])

def main():
    parser = argparse.ArgumentParser(description="LexisAI E2E Automation Runner")
    parser.add_argument(
        "--mode", 
        choices=["real", "dry-run"], 
        default="dry-run", 
        help="Execution mode: 'real' connects to Appium server; 'dry-run' simulates driver operations."
    )
    args = parser.parse_args()
    
    # Configure SIMULATE_TESTS env var based on mode
    if args.mode == "dry-run":
        os.environ["SIMULATE_TESTS"] = "true"
        print("Starting test suite in DRY-RUN/SIMULATION mode...")
    else:
        os.environ["SIMULATE_TESTS"] = "false"
        print("Starting test suite in REAL Appium mode...")

        
    # Get automation base and project root directory
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    project_root = os.path.dirname(base_dir)
    tests_dir = os.path.join(base_dir, "tests")
    
    # Configure PYTHONPATH to include the project root so "automation" resolves
    env = os.environ.copy()
    env["PYTHONPATH"] = project_root + os.pathsep + env.get("PYTHONPATH", "")
    
    # Execute pytest via subprocess to ensure clean process space
    cmd = [sys.executable, "-m", "pytest", os.path.join(tests_dir, "test_suite.py"), "-v", "--tb=short"]
    
    print(f"Executing: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=project_root, env=env)
    
    # Analyze exit code
    # Pytest exit codes: 0 = all tests passed, 1 = some tests failed, 2 = interrupted, 5 = no tests run
    if result.returncode in [0, 1]:
        print("\nTest execution finished successfully.")
        # Load summary file to display stats
        summary_path = os.path.join(base_dir, "summary.md")
        if os.path.exists(summary_path):
            if hasattr(sys.stdout, "reconfigure"):
                try:
                    sys.stdout.reconfigure(encoding='utf-8')
                except Exception:
                    pass
            with open(summary_path, "r", encoding="utf-8") as f:
                content = f.read()
                try:
                    print(content)
                except UnicodeEncodeError:
                    print(content.encode('ascii', errors='replace').decode('ascii'))
        sys.exit(0)
    else:
        print(f"\nPytest run failed with code {result.returncode}")
        sys.exit(result.returncode)

if __name__ == "__main__":
    main()
