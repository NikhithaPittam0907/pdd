from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from automation.utils.logger_util import logger
from automation.config import config

class BasePage:
    def __init__(self, driver):
        self.driver = driver
        self.timeout = 10
        
    def navigate(self, path=""):
        url = f"{config.BASE_URL.rstrip('/')}/{path.lstrip('/')}"
        logger.info(f"Navigating browser to: {url}")
        self.driver.get(url)
        
    def find_element(self, locator):
        logger.debug(f"Locating element: {locator}")
        if hasattr(self.driver, "find_element"):
            return self.driver.find_element(*locator)
        raise AttributeError("Driver does not support find_element")
        
    def click(self, locator):
        logger.info(f"Clicking element: {locator}")
        element = self.find_element(locator)
        element.click()
        
    def enter_text(self, locator, text):
        logger.info(f"Entering text '{text}' into element: {locator}")
        element = self.find_element(locator)
        element.send_keys(text)
        
    def get_text(self, locator):
        element = self.find_element(locator)
        text = element.text
        logger.debug(f"Got text '{text}' from element: {locator}")
        return text

    def is_element_displayed(self, locator):
        try:
            element = self.find_element(locator)
            return element.is_displayed()
        except Exception:
            return False
            
    def get_current_url(self):
        return getattr(self.driver, "current_url", "")
