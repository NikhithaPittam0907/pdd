from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class LoginPage(BasePage):
    # Locators
    EMAIL_FIELD = (By.CSS_SELECTOR, "#email_field, input[type='email']")
    PASSWORD_FIELD = (By.CSS_SELECTOR, "#password_field, input[type='password']")
    SIGNIN_BUTTON = (By.CSS_SELECTOR, "#signin_button, button.signin")
    SIGNUP_LINK = (By.CSS_SELECTOR, "#signup_link, a.signup")
    
    # Sign Up Locators
    NAME_FIELD = (By.CSS_SELECTOR, "#name_field, input[name='name']")
    CONFIRM_PASSWORD_FIELD = (By.CSS_SELECTOR, "#confirm_password_field, input[name='confirm_password']")
    SIGNUP_BUTTON = (By.CSS_SELECTOR, "#signup_button, button.register")
    
    def navigate_to_login(self):
        self.navigate("/#/signin")
        
    def login(self, email, password):
        self.enter_text(self.EMAIL_FIELD, email)
        self.enter_text(self.PASSWORD_FIELD, password)
        self.click(self.SIGNIN_BUTTON)
        
    def register(self, name, email, password):
        self.click(self.SIGNUP_LINK)
        self.enter_text(self.NAME_FIELD, name)
        self.enter_text(self.EMAIL_FIELD, email)
        self.enter_text(self.PASSWORD_FIELD, password)
        self.enter_text(self.CONFIRM_PASSWORD_FIELD, password)
        self.click(self.SIGNUP_BUTTON)
