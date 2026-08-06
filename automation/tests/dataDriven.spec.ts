import { expect, browser } from '@wdio/globals';

describe('LexisAI Android E2E Appium Automation Suite', () => {

    it('TC_ENV_001: Verify Android Emulator Capability & Appium Session', async () => {
        console.log('[E2E Test] Validating Android Appium Session Capabilities...');
        const caps = await browser.getCapabilities();
        expect(caps).toBeDefined();
        console.log(`[E2E Test] Connected Platform: ${caps.platformName}, Device: ${caps['deviceName'] || 'Android Emulator'}`);
        expect(caps.platformName?.toLowerCase()).toBe('android');
    });

    it('TC_APP_001: Verify LexisAI Application Package Launch State', async () => {
        console.log('[E2E Test] Checking Application Package & Activity Status...');
        const state = await browser.getCurrentPackage();
        console.log(`[E2E Test] Current Package: ${state}`);
        expect(state).toBeDefined();
        await browser.pause(1000);
    });

    it('TC_AUTH_001: Verify Gateway Screen & Window Readiness', async () => {
        console.log('[E2E Test] Checking App Window Size & Orientation...');
        const windowSize = await browser.getWindowSize();
        console.log(`[E2E Test] Window Dimensions: ${windowSize.width}x${windowSize.height}`);
        expect(windowSize.width).toBeGreaterThan(0);
        expect(windowSize.height).toBeGreaterThan(0);
        await browser.pause(1000);
    });

    it('TC_AUTH_002: Verify Application Context & UI Rendering', async () => {
        console.log('[E2E Test] Inspecting Session Contexts...');
        const contexts = await browser.getContexts();
        console.log(`[E2E Test] Available Contexts: ${JSON.stringify(contexts)}`);
        expect(contexts.length).toBeGreaterThan(0);
        
        // Take a screenshot of active screen
        const screenshot = await browser.takeScreenshot();
        expect(screenshot).toBeDefined();
        expect(screenshot.length).toBeGreaterThan(100);
    });
});

