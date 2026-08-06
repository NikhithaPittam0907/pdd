const { By, until } = require('selenium-webdriver');
const SeleniumUtils = require('../utilities/SeleniumUtils');
const config = require('../config/config');
const logger = require('../utilities/WinstonLogger');

class BasePage {
  constructor(driver) {
    this.driver = driver;
  }

  async open(path = '/') {
    const url = `${config.baseUrl}${path}`;
    logger.info(`[BasePage] Opening URL: ${url}`);
    await this.driver.get(url);
    await this.waitForPageLoad();
  }

  async getTitle() {
    return await this.driver.getTitle();
  }

  async getCurrentUrl() {
    return await this.driver.getCurrentUrl();
  }

  async waitForPageLoad() {
    await this.driver.wait(async (d) => {
      const state = await d.executeScript('return document.readyState');
      return state === 'complete';
    }, config.timeout);
  }

  async isElementPresent(locator) {
    try {
      const els = await this.driver.findElements(locator);
      return els.length > 0;
    } catch (_) {
      return false;
    }
  }

  async isElementDisplayed(locator) {
    try {
      const el = await SeleniumUtils.waitForVisible(this.driver, locator, 5000);
      return await el.isDisplayed();
    } catch (_) {
      return false;
    }
  }

  async getText(locator) {
    const el = await SeleniumUtils.waitForVisible(this.driver, locator);
    return await el.getText();
  }

  async click(locator) {
    logger.info(`[BasePage] Clicking element located by: ${locator.toString()}`);
    await SeleniumUtils.clickWhenReady(this.driver, locator);
  }

  async type(locator, text) {
    logger.info(`[BasePage] Typing into element [${locator.toString()}]: ${text}`);
    await SeleniumUtils.sendKeysWithWait(this.driver, locator, text);
  }
}

module.exports = BasePage;
