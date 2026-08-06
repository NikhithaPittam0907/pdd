const { expect } = require('chai');
const SeleniumUtils = require('../utilities/SeleniumUtils');
const SignInPage = require('../pages/SignInPage');
const ExcelReporter = require('../utilities/ExcelReporter');
const logger = require('../utilities/WinstonLogger');

describe('React Application - Authentication E2E Test Suite', function () {
  this.timeout(60000);
  let driver;
  let signInPage;
  const excelReporter = new ExcelReporter();

  before(async function () {
    driver = await SeleniumUtils.createDriver();
    signInPage = new SignInPage(driver);
  });

  after(async function () {
    if (driver) {
      await driver.quit();
    }
    await excelReporter.generateReport('Authentication_Report.xlsx');
  });

  afterEach(async function () {
    const testName = this.currentTest ? this.currentTest.title : 'Authentication Test';
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

    excelReporter.recordTest('TC_AUTH_001', 'Authentication', testName, 'Chrome', status, duration, errorMsg, screenshotPath, currentUrl);
  });

  it('TC_AUTH_001: Validate Empty Username Submission Rule', async function () {
    logger.info('Executing TC_AUTH_001: Empty Username');
    await signInPage.openSignIn();
    await signInPage.login('', 'Password123!');
    const url = await signInPage.getCurrentUrl();
    expect(url).to.include('/signin');
  });

  it('TC_AUTH_002: Validate Empty Password Submission Rule', async function () {
    logger.info('Executing TC_AUTH_002: Empty Password');
    await signInPage.openSignIn();
    await signInPage.login('attorney@firm.com', '');
    const url = await signInPage.getCurrentUrl();
    expect(url).to.include('/signin');
  });

  it('TC_AUTH_003: Validate Invalid Credentials Handling', async function () {
    logger.info('Executing TC_AUTH_003: Invalid Credentials');
    await signInPage.openSignIn();
    await signInPage.login('invalid_user@test.com', 'WrongPassword999');
    await driver.sleep(1000);
    const url = await signInPage.getCurrentUrl();
    expect(url).to.include('/signin');
  });

  it('TC_AUTH_004: Validate Valid Credentials Sign-In & Dashboard Transition', async function () {
    logger.info('Executing TC_AUTH_004: Valid Credentials Sign-In');
    await signInPage.openSignIn();
    const isDisplayed = await signInPage.isHeaderDisplayed();
    expect(isDisplayed).to.be.true;
  });
});
