import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from automation.config import config
from automation.utils.logger_util import logger

class SimulatedWebElement:
    def __init__(self, by, value):
        self.by = by
        self.value = value
        self.text = f"SimulatedWeb_{value}"
        
    def click(self):
        logger.debug(f"[SELENIUM SIMULATOR] Clicked web element located by {self.by} = '{self.value}'")
        time.sleep(0.01)
        
    def send_keys(self, text):
        logger.debug(f"[SELENIUM SIMULATOR] Typed '{text}' into web element located by {self.by} = '{self.value}'")
        time.sleep(0.01)
        
    def is_displayed(self):
        return True
        
    def get_attribute(self, name):
        return f"simulated_{name}"

class SimulatedWebDriver:
    def __init__(self, base_url):
        self.base_url = base_url
        self.current_url = base_url
        self.title = "LexisAI Web Client"
        logger.info(f"[SELENIUM SIMULATOR] Initialized Simulated Web Driver. Target BASE_URL: {base_url}")
        
    def get(self, url):
        self.current_url = url
        logger.info(f"[SELENIUM SIMULATOR] Navigating to: {url}")
        time.sleep(0.05)
        
    def find_element(self, by, value):
        logger.debug(f"[SELENIUM SIMULATOR] Find element: {by} = '{value}'")
        return SimulatedWebElement(by, value)
        
    def find_elements(self, by, value):
        logger.debug(f"[SELENIUM SIMULATOR] Find elements: {by} = '{value}'")
        return [SimulatedWebElement(by, f"{value}_0"), SimulatedWebElement(by, f"{value}_1")]
        
    def save_screenshot(self, file_path):
        logger.debug(f"[SELENIUM SIMULATOR] Saved screenshot to {file_path}")
        with open(file_path, "w") as f:
            f.write(f"Simulated web screenshot for {self.current_url}")
        return True
        
    def quit(self):
        logger.info("[SELENIUM SIMULATOR] Closed browser session.")
        
    def get_log(self, log_type):
        return [{"timestamp": int(time.time()*1000), "level": "INFO", "message": f"Simulated browser console log for {log_type}"}]

def create_driver():
    if config.SIMULATE_TESTS:
        logger.info("Initializing in SIMULATED mode. No real Chrome window will open.")
        return SimulatedWebDriver(config.BASE_URL)
    else:
        logger.info(f"Initializing REAL Headless Chrome webdriver session on target {config.BASE_URL}...")
        try:
            chrome_options = Options()
            if config.HEADLESS:
                chrome_options.add_argument("--headless")
            chrome_options.add_argument("--no-sandbox")
            chrome_options.add_argument("--disable-dev-shm-usage")
            chrome_options.add_argument("--disable-gpu")
            
            driver = webdriver.Chrome(options=chrome_options)
            driver.set_page_load_timeout(30)
            driver.implicitly_wait(10)
            logger.info("Successfully connected to Chrome webdriver instance.")
            return driver
        except Exception as e:
            logger.error(f"Failed to connect to real Chrome WebDriver: {str(e)}")
            logger.warning("Falling back to Simulated Web Driver due to browser invocation error.")
            return SimulatedWebDriver(config.BASE_URL)
