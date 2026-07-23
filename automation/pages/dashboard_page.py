from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class DashboardPage(BasePage):
    # Web Locators
    DASHBOARD_TITLE = (By.CSS_SELECTOR, "h1.dashboard-title, .dashboard-header")
    CASES_TAB = (By.CSS_SELECTOR, "#cases_tab, a.cases")
    APPOINTMENTS_TAB = (By.CSS_SELECTOR, "#appointments_tab, a.appointments")
    BILLING_TAB = (By.CSS_SELECTOR, "#billing_tab, a.billing")
    PROFILE_TAB = (By.CSS_SELECTOR, "#profile_tab, a.profile")
    
    # Specific cards
    DOMESTIC_VIOLENCE_CARD = (By.CSS_SELECTOR, "#domestic_violence_card, .card-domestic")
    ACCIDENT_CLAIM_CARD = (By.CSS_SELECTOR, "#accident_claim_card, .card-accident")
    CYBER_CRIME_CARD = (By.CSS_SELECTOR, "#cyber_crime_card, .card-cyber")
    
    # Admin Cards
    ANALYTICS_CARD = (By.CSS_SELECTOR, "#analytics_card, .card-analytics")
    LAWYER_MGMT_CARD = (By.CSS_SELECTOR, "#lawyer_management_card, .card-lawyers")
    
    def navigate_to_tab(self, tab_locator):
        self.click(tab_locator)
        
    def start_domestic_violence_flow(self):
        self.click(self.DOMESTIC_VIOLENCE_CARD)
        
    def open_analytics(self):
        self.click(self.ANALYTICS_CARD)
