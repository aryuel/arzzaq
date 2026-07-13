<?php

return [
    'guard' => 'internal',
    'middleware' => ['web'],
    'auth_middleware' => 'auth:internal',
    'passwords' => null,
    'username' => 'username',
    'email' => 'username',
    'views' => false,
    'home' => '/',
    'prefix' => 'api/v1/auth/internal',
    'domain' => null,
    'lowercase_usernames' => true,
    'limiters' => [
        'login' => null,
        'passkeys' => null,
    ],
    // Pipeline TOTP khusus Arzzaq diaktifkan dan diuji pada Fase 5.
    // Passkey tidak termasuk scope versi pertama.
    'features' => [],
];
