<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Route;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

final class BootstrapApplicationTest extends TestCase
{
    #[Test]
    public function halaman_skeleton_dapat_dimuat_tanpa_mengekspos_data_domain(): void
    {
        $this->withoutVite();

        $this->get('/')
            ->assertOk()
            ->assertSee('<div id="app"></div>', false)
            ->assertHeaderMissing('X-Powered-By');
    }

    #[Test]
    public function endpoint_kesehatan_mengembalikan_status_up(): void
    {
        $this->getJson('/up')
            ->assertOk()
            ->assertExactJson(['status' => 'up']);
    }

    #[Test]
    public function route_autentikasi_dan_storage_bawaan_tidak_terekspos(): void
    {
        $this->assertFalse(Route::has('login'));
        $this->assertFalse(Route::has('register'));
        $this->assertFalse(Route::has('passkey.login'));
        $this->assertFalse(Route::has('storage.local'));
        $this->assertTrue(Route::has('sanctum.csrf-cookie'));
    }
}
