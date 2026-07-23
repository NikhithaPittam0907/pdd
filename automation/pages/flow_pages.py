from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class DomesticViolenceFlowPage(BasePage):
    # Web Locators
    INCIDENT_DESCRIPTION = (By.CSS_SELECTOR, "#incident_description_field, textarea.description")
    RELATIONSHIP_TYPE = (By.CSS_SELECTOR, "#relationship_type_dropdown, select.relationship")
    ANONYMOUS_SWITCH = (By.CSS_SELECTOR, "#anonymous_switch, input[type='checkbox'].anonymous")
    SUBMIT_REPORT_BUTTON = (By.CSS_SELECTOR, "#submit_report_button, button.submit-report")
    SUCCESS_BANNER = (By.CSS_SELECTOR, ".success-banner, #success_message")
    
    def submit_report(self, description, relationship, anonymous=True):
        self.enter_text(self.INCIDENT_DESCRIPTION, description)
        self.enter_text(self.RELATIONSHIP_TYPE, relationship)
        # Checkbox logic
        if anonymous:
            checkbox = self.find_element(self.ANONYMOUS_SWITCH)
            if not checkbox.is_selected() if hasattr(checkbox, 'is_selected') else False:
                self.click(self.ANONYMOUS_SWITCH)
        self.click(self.SUBMIT_REPORT_BUTTON)

class AccidentClaimFlowPage(BasePage):
    VEHICLE_NUMBER = (By.CSS_SELECTOR, "#vehicle_number_field, input.vehicle-no")
    INSURANCE_PROVIDER = (By.CSS_SELECTOR, "#insurance_provider_field, input.insurance")
    SUBMIT_CLAIM_BUTTON = (By.CSS_SELECTOR, "#submit_claim_button, button.submit-claim")
    
    def submit_claim(self, vehicle_no, insurer):
        self.enter_text(self.VEHICLE_NUMBER, vehicle_no)
        self.enter_text(self.INSURANCE_PROVIDER, insurer)
        self.click(self.SUBMIT_CLAIM_BUTTON)

class DocumentUploadPage(BasePage):
    SELECT_FILE_BUTTON = (By.CSS_SELECTOR, "#select_file_button, input[type='file']")
    UPLOAD_CONFIRM_BUTTON = (By.CSS_SELECTOR, "#upload_confirm_button, button.upload")
    
    def upload_document(self, file_path):
        self.enter_text(self.SELECT_FILE_BUTTON, file_path)
        self.click(self.UPLOAD_CONFIRM_BUTTON)
