const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const firefox = require('selenium-webdriver/firefox');
const edge = require('selenium-webdriver/edge');
const fs = require('fs');
const path = require('path');
const config = require('../config/config');
const logger = require('./WinstonLogger');

class SeleniumUtils {
  static async createDriver(browserName = config.browser, isHeadless = config.headless) {
    logger.info(`Initializing Selenium WebDriver for [${browserName.toUpperCase()}] (Headless: ${isHeadless})`);
    let builder = new Builder();

    switch (browserName.toLowerCase()) {
      case 'firefox': {
        const options = new firefox.Options();
        if (isHeadless) options.addArguments('-headless');
        builder = builder.forBrowser('firefox').setFirefoxOptions(options);
        break;
      }
      case 'edge': {
        const options = new edge.Options();
        if (isHeadless) options.addArguments('--headless');
        builder = builder.forBrowser('MicrosoftEdge').setEdgeOptions(options);
        break;
      }
      case 'chrome':
      default: {
        const options = new chrome.Options();
        options.addArguments('--no-sandbox');
        options.addArguments('--disable-dev-shm-usage');
        options.addArguments('--disable-gpu');
        options.addArguments('--window-size=1920,1080');
        if (isHeadless) options.addArguments('--headless=new');
        builder = builder.forBrowser('chrome').setChromeOptions(options);
        break;
      }
    }

    const driver = await builder.build();
    await driver.manage().setTimeouts({ implicit: 5000, pageLoad: 30000 });
    return driver;
  }

  static async waitForElement(driver, locator, timeout = config.timeout) {
    return await driver.wait(until.elementLocated(locator), timeout);
  }

  static async waitForVisible(driver, locator, timeout = config.timeout) {
    const el = await this.waitForElement(driver, locator, timeout);
    await driver.wait(until.elementIsVisible(el), timeout);
    return el;
  }

  static async clickWhenReady(driver, locator, timeout = config.timeout) {
    const el = await this.waitForVisible(driver, locator, timeout);
    await driver.wait(until.elementIsEnabled(el), timeout);
    await el.click();
    return el;
  }

  static async sendKeysWithWait(driver, locator, text, timeout = config.timeout) {
    const el = await this.waitForVisible(driver, locator, timeout);
    await el.clear();
    await el.sendKeys(text);
    return el;
  }

  static async scrollToElement(driver, element) {
    await driver.executeScript("arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", element);
  }

  static async handleFailure(driver, testName) {
    const failureDir = config.paths.failures;
    if (!fs.existsSync(failureDir)) {
      fs.mkdirSync(failureDir, { recursive: true });
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const sanitizeName = testName.replace(/[^a-zA-Z0-9]/g, '_');
    const screenshotFileName = `FAIL_${sanitizeName}_${timestamp}.png`;
    const screenshotPath = path.join(failureDir, screenshotFileName);

    let currentUrl = 'Unknown';
    let consoleLogs = [];

    try {
      if (driver) {
        currentUrl = await driver.getCurrentUrl();
        const screenshotData = await driver.takeScreenshot();
        fs.writeFileSync(screenshotPath, screenshotData, 'base64');
        logger.error(`[Failure Screenshot] Saved screenshot to: ${screenshotPath}`);

        try {
          consoleLogs = await driver.manage().logs().get('browser');
        } catch (_) {}
      }
    } catch (err) {
      logger.error(`[Failure Handler Error] Could not capture screenshot/logs: ${err.message}`);
    }

    return {
      screenshotPath,
      currentUrl,
      consoleLogs: JSON.stringify(consoleLogs)
    };
  }
}

module.exports = SeleniumUtils;
