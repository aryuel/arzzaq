<?php

use App\Models\InternalUser;
use App\Models\Keluarga;

return [
    'defaults' => [
        'guard' => env('AUTH_GUARD', 'keluarga'),
        'passwords' => null,
    ],

    'guards' => [
        'keluarga' => [
            'driver' => 'session',
            'provider' => 'keluarga',
        ],
        'internal' => [
            'driver' => 'session',
            'provider' => 'internal_users',
        ],
    ],

    'providers' => [
        'keluarga' => [
            'driver' => 'eloquent',
            'model' => Keluarga::class,
        ],
        'internal_users' => [
            'driver' => 'eloquent',
            'model' => InternalUser::class,
        ],
    ],

    // Reset credential Arzzaq menggunakan OTP grant atau prosedur Super Admin,
    // bukan password-reset broker berbasis email milik Laravel.
    'passwords' => [],

    'password_timeout' => env('AUTH_PASSWORD_TIMEOUT', 900),
];
