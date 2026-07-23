import os
import json
import pytest
from automation.drivers.driver_factory import create_driver
from automation.pages.login_page import LoginPage
from automation.pages.dashboard_page import DashboardPage
from automation.pages.flow_pages import DomesticViolenceFlowPage, AccidentClaimFlowPage, DocumentUploadPage
from automation.utils.logger_util import logger
from automation.utils.screenshot_util import capture_screenshot

# Load pre-generated test cases
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
json_path = os.path.join(base_dir, "data", "test_cases.json")

if os.path.exists(json_path):
    with open(json_path, "r", encoding="utf-8") as f:
        TEST_CASES_DATA = json.load(f)
else:
    TEST_CASES_DATA = []

@pytest.fixture(scope="module")
def driver():
    # Setup Selenium browser driver
    drv = create_driver()
    yield drv
    # Teardown
    drv.quit()

@pytest.mark.parametrize("test_case", TEST_CASES_DATA, ids=lambda tc: tc["testId"])
def test_execute_chain(driver, test_case):
    test_id = test_case["testId"]
    module = test_case["module"]
    test_name = test_case["testName"]
    status = test_case["status"]
    reason = test_case["reason"]
    
    logger.info(f"--- STARTING WEB TEST: {test_id} - {test_name} [{module}] ---")
    
    # 1. Skip check
    if status == "Skipped":
        logger.warning(f"Skipping test case {test_id} because: {reason}")
        pytest.skip(reason)
        
    # 2. Page Object Initializations
    login_page = LoginPage(driver)
    dashboard_page = DashboardPage(driver)
    dv_page = DomesticViolenceFlowPage(driver)
    accident_page = AccidentClaimFlowPage(driver)
    upload_page = DocumentUploadPage(driver)
    
    try:
        # 3. Perform web POM actions depending on module
        logger.info(f"Precondition: {test_case['preconditions']}")
        
        # Navigate to target page
        login_page.navigate_to_login()
        
        if module == "Authentication":
            if "Valid Login" in test_name:
                login_page.login("client@lexisai.com", "SecurePassword123")
            elif "Logout" in test_name:
                login_page.login("client@lexisai.com", "SecurePassword123")
                dashboard_page.navigate_to_tab(dashboard_page.PROFILE_TAB)
            else:
                login_page.login(f"user_{test_id}@example.com", "pass123")
                
        elif module == "Forms":
            dashboard_page.start_domestic_violence_flow()
            dv_page.submit_report("Domestic dispute incident report details", "Spouse", anonymous=True)
            
        elif module == "File Upload":
            upload_page.upload_document(f"/sdcard/documents/{test_id}_doc.pdf")
            
        else:
            dashboard_page.navigate_to_tab(dashboard_page.DASHBOARD_TITLE)
            
        # 4. Check for failures
        if status == "Failed":
            raise AssertionError(f"Simulated failure: {reason}")
            
        logger.info(f"--- PASSED WEB TEST: {test_id} ---")
        
    except AssertionError as e:
        capture_screenshot(driver, test_id, name="assertion_failure")
        logger.error(f"--- FAILED WEB TEST: {test_id} - Reason: {str(e)} ---")
        raise e
        
    except Exception as e:
        capture_screenshot(driver, test_id, name="error_failure")
        logger.error(f"--- FAILED WEB TEST: {test_id} due to unexpected error: {str(e)} ---")
        raise e
