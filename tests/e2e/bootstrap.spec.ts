import { expect, test } from '@playwright/test';

test('skeleton aplikasi dapat dimuat', async ({ page }) => {
    await page.goto('/');

    await expect(page).toHaveTitle('Arzzaq');
    await expect(page.locator('[data-application-ready="true"]')).toHaveCount(1);
});
