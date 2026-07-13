<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;

final class InternalUser extends Authenticatable
{
    protected $table = 'internal_users';

    protected $hidden = [
        'password_hash',
        'totp_secret_encrypted',
        'totp_last_used_step',
    ];

    public function getAuthIdentifierName(): string
    {
        return 'username';
    }

    public function getAuthPasswordName(): string
    {
        return 'password_hash';
    }

    protected function casts(): array
    {
        return [
            'wajib_ganti_password' => 'boolean',
            'totp_confirmed_at' => 'immutable_datetime',
            'totp_secret_encrypted' => 'encrypted',
        ];
    }
}
