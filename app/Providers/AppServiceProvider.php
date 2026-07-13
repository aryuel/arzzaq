<?php

namespace App\Providers;

use App\Support\Environment\ProductionEnvironmentGuard;
use Illuminate\Support\ServiceProvider;
use Laravel\Fortify\Fortify;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Semua endpoint autentikasi memakai kontrak /api/v1 milik Arzzaq.
        // Route bawaan Fortify, termasuk passkey, tidak boleh terekspos.
        Fortify::ignoreRoutes();
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (! $this->app->isProduction()) {
            return;
        }

        $applicationUrl = rtrim((string) config('app.url'), '/');
        $corsOrigins = config('cors.allowed_origins');
        $reverbOrigins = config('reverb.apps.apps.0.allowed_origins');

        (new ProductionEnvironmentGuard)->validate([
            'APP_DEBUG' => config('app.debug') === false,
            'APP_URL' => parse_url($applicationUrl, PHP_URL_SCHEME) === 'https',
            'DB_CONNECTION' => config('database.default') === 'pgsql',
            'CACHE_STORE' => config('cache.default') === 'redis',
            'QUEUE_CONNECTION' => config('queue.default') === 'redis',
            'SESSION_DRIVER' => config('session.driver') === 'redis',
            'SESSION_ENCRYPT' => config('session.encrypt') === true,
            'SESSION_SECURE_COOKIE' => config('session.secure') === true,
            'CORS_ALLOWED_ORIGINS' => $corsOrigins === [$applicationUrl],
            'REVERB_ALLOWED_ORIGINS' => $reverbOrigins === [$applicationUrl],
            'REVERB_APP_ID' => filled(config('reverb.apps.apps.0.app_id')),
            'REVERB_APP_KEY' => filled(config('reverb.apps.apps.0.key')),
            'REVERB_APP_SECRET' => filled(config('reverb.apps.apps.0.secret')),
        ]);
    }
}
