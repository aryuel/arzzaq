import { expect, test } from '@playwright/test';

test('skeleton aplikasi dapat dimuat', async ({ page }) => {
    const galatHalaman: string[] = [];
    const permintaanGagal: string[] = [];

    page.on('pageerror', (error) => galatHalaman.push(error.message));
    page.on('requestfailed', (request) => {
        permintaanGagal.push(`${request.url()}: ${request.failure()?.errorText ?? 'tidak diketahui'}`);
    });

    const response = await page.goto('/');

    expect(response?.status()).toBe(200);

    await expect(page).toHaveTitle('Arzzaq');
    await expect(page.locator('[data-application-ready="true"]')).toHaveCount(1);
    expect(galatHalaman).toEqual([]);
    expect(permintaanGagal).toEqual([]);
});
