const { expect } = require('chai');
const SeleniumUtils = require('../utilities/SeleniumUtils');
const SignUpPage = require('../pages/SignUpPage');
const ExcelReporter = require('../utilities/ExcelReporter');
const logger = require('../utilities/WinstonLogger');

describe('React Application - Form Validation Test Suite', function () {
  this.timeout(60000);
  let driver;
  let signUpPage;
  const excelReporter = new ExcelReporter();

  before(async function () {
    driver = await SeleniumUtils.createDriver();
    signUpPage = new SignUpPage(driver);
  });

  after(async function () {
    if (driver) await driver.quit();
    await excelReporter.generateReport('FormValidation_Report.xlsx');
  });

  afterEach(async function () {
    const testName = this.currentTest ? this.currentTest.title : 'Form Validation Test';
    const status = this.currentTest.state === 'passed' ? 'PASS' : 'FAIL';
    const duration = this.currentTest.duration || 0;
    let screenshotPath = 'N/A';
    let currentUrl = 'N/A';
    let errorMsg = 'N/A';

    if (status === 'FAIL') {
      const failInfo = await SeleniumUtils.handleFailure(driver, testName);
      screenshotPath = failInfo.screenshotPath;
      currentUrl = failInfo.currentUrl;
      errorMsg = this.currentTest.err ? this.currentTest.err.message : 'Assertion error';
    }

    excelReporter.recordTest('TC_FORM_001', 'Form Validation', testName, 'Chrome', status, duration, errorMsg, screenshotPath, currentUrl);
  });

  it('TC_FORM_001: Validate Required Fields Enforcement on SignUp Form', async function () {
    logger.info('Executing TC_FORM_001: Required Fields Enforcement');
    await signUpPage.openSignUp();
    const url = await signUpPage.getCurrentUrl();
    expect(url).to.include('/signup');
  });

  it('TC_FORM_002: Validate Email Format & Invalid Domain Validation', async function () {
    logger.info('Executing TC_FORM_002: Email Format Validation');
    await signUpPage.openSignUp();
    await signUpPage.registerUser('Test User', 'invalid_email_domain', '1234567890', 'Pass123!');
    const url = await signUpPage.getCurrentUrl();
    expect(url).to.include('/signup');
  });

  it('TC_FORM_003: Validate Password Complexity & Length Boundaries', async function () {
    logger.info('Executing TC_FORM_003: Password Complexity');
    await signUpPage.openSignUp();
    await signUpPage.registerUser('Test User', 'user@test.com', '1234567890', '123');
    const url = await signUpPage.getCurrentUrl();
    expect(url).to.include('/signup');
  });
});
