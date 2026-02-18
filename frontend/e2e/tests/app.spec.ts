import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
    // Replace with your local Flutter web URL
    await page.goto('http://localhost:63441');

    // Expect a title "to contain" a substring.
    await expect(page).toHaveTitle(/lifeline/i);
});
