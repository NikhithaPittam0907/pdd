const { By } = require('selenium-webdriver');
const BasePage = require('./BasePage');

class DashboardPage extends BasePage {
  constructor(driver) {
    super(driver);
    this.dashboardTitle = By.xpath("//*[contains(text(), 'Dashboard') or contains(text(), 'LexisAI')]");
    this.sidebarLinks = By.css('nav a, .sidebar a, [role="navigation"] a');
    this.userProfileBtn = By.css('.profile-icon, [aria-label="Account Settings"]');
    this.logoutBtn = By.xpath("//*[contains(text(), 'Logout') or contains(text(), 'Sign Out')]");
  }

  async isDashboardLoaded() {
    return await this.isElementDisplayed(this.dashboardTitle);
  }

  async logout() {
    if (await this.isElementPresent(this.userProfileBtn)) {
      await this.click(this.userProfileBtn);
    }
    await this.click(this.logoutBtn);
  }
}

module.exports = DashboardPage;
