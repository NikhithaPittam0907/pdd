const { By } = require('selenium-webdriver');
const BasePage = require('./BasePage');

class SignInPage extends BasePage {
  constructor(driver) {
    super(driver);
    
    // Locators
    this.emailInput = By.css('input[type="email"], input[hint*="attorney"], input[name="email"]');
    this.passwordInput = By.css('input[type="password"], input[name="password"]');
    this.signInButton = By.xpath("//button[contains(., 'Sign In')]");
    this.googleSignInBtn = By.xpath("//button[contains(., 'Google')]");
    this.forgotPasswordLink = By.xpath("//*[contains(text(), 'Forgot Password')]");
    this.signUpLink = By.xpath("//*[contains(text(), 'Sign Up')]");
    this.rememberMeCheckbox = By.css('input[type="checkbox"]');
    this.headerText = By.xpath("//*[contains(text(), 'LexisCore Login')]");
    this.snackBarMessage = By.css('.MuiSnackbar-root, .snackbar, [role="alert"]');
  }

  async openSignIn() {
    await this.open('/signin');
  }

  async login(email, password) {
    if (email !== null) await this.type(this.emailInput, email);
    if (password !== null) await this.type(this.passwordInput, password);
    await this.click(this.signInButton);
  }

  async clickGoogleSignIn() {
    await this.click(this.googleSignInBtn);
  }

  async clickSignUp() {
    await this.click(this.signUpLink);
  }

  async isHeaderDisplayed() {
    return await this.isElementDisplayed(this.headerText);
  }
}

module.exports = SignInPage;
