<?php

namespace Tests\Unit\Support\Environment;

use App\Support\Environment\ProductionEnvironmentGuard;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;
use RuntimeException;

final class ProductionEnvironmentGuardTest extends TestCase
{
    #[Test]
    public function menerima_seluruh_konfigurasi_yang_aman(): void
    {
        (new ProductionEnvironmentGuard)->validate([
            'APP_DEBUG' => true,
            'APP_URL' => true,
        ]);

        $this->addToAssertionCount(1);
    }

    #[Test]
    public function menolak_konfigurasi_tidak_aman_tanpa_menampilkan_nilainya(): void
    {
        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('Konfigurasi production tidak aman: APP_DEBUG, SESSION_SECURE_COOKIE.');

        (new ProductionEnvironmentGuard)->validate([
            'APP_DEBUG' => false,
            'APP_URL' => true,
            'SESSION_SECURE_COOKIE' => false,
        ]);
    }
}
