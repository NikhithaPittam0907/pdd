import os
import time
from automation.utils.logger_util import logger

def capture_screenshot(driver, test_id, name="failure"):
    # Ensure screenshots folder exists
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    screenshot_dir = os.path.join(base_dir, "screenshots")
    os.makedirs(screenshot_dir, exist_ok=True)
    
    timestamp = int(time.time())
    file_name = f"{test_id}_{name}_{timestamp}.png"
    file_path = os.path.join(screenshot_dir, file_name)
    
    try:
        if hasattr(driver, "save_screenshot"):
            driver.save_screenshot(file_path)
            logger.info(f"Captured screenshot: {file_path}")
        else:
            # Simulated driver
            with open(file_path, "w") as f:
                f.write(f"SIMULATED SCREENSHOT FOR TEST {test_id} - {name}")
            logger.info(f"Captured simulated screenshot: {file_path}")
        return file_path
    except Exception as e:
        logger.error(f"Failed to capture screenshot for test {test_id}: {str(e)}")
        return None
