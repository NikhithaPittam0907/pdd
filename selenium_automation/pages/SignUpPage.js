const { By } = require('selenium-webdriver');
const BasePage = require('./BasePage');

class SignUpPage extends BasePage {
  constructor(driver) {
    super(driver);
    this.nameInput = By.css('input[name="name"], input[placeholder*="Name"]');
    this.emailInput = By.css('input[type="email"], input[name="email"]');
    this.phoneInput = By.css('input[type="tel"], input[name="phone"]');
    this.passwordInput = By.css('input[type="password"], input[name="password"]');
    this.confirmPasswordInput = By.css('input[name="confirmPassword"]');
    this.roleDropdown = By.css('select[name="role"]');
    this.termsCheckbox = By.css('input[type="checkbox"]');
    this.submitBtn = By.xpath("//button[contains(., 'Sign Up') or contains(., 'Register')]");
    this.signInLink = By.xpath("//*[contains(text(), 'Sign In')]");
  }

  async openSignUp() {
    await this.open('/signup');
  }

  async registerUser(name, email, phone, password, role = 'client') {
    if (name) await this.type(this.nameInput, name);
    if (email) await this.type(this.emailInput, email);
    if (phone) await this.type(this.phoneInput, phone);
    if (password) await this.type(this.passwordInput, password);
    await this.click(this.submitBtn);
  }
}

module.exports = SignUpPage;
