import { browser } from '@wdio/globals';

export default class BasePage {
    /**
     * Wait for an element to be displayed and then click it
     * @param element 
     */
    protected async clickElement(element: WebdriverIO.Element) {
        await element.waitForDisplayed({ timeout: 10000 });
        await element.click();
    }

    /**
     * Wait for an element, clear existing value, and set new value
     * @param element 
     * @param value 
     */
    protected async setValue(element: WebdriverIO.Element, value: string) {
        await element.waitForDisplayed({ timeout: 10000 });
        await element.clearValue();
        await element.setValue(value);
    }

    /**
     * Check if element is displayed
     * @param element 
     * @returns boolean
     */
    protected async isDisplayed(element: WebdriverIO.Element): Promise<boolean> {
        try {
            await element.waitForDisplayed({ timeout: 5000 });
            return true;
        } catch (error) {
            return false;
        }
    }
}
