<?php

namespace App\Models;

use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;

final class Keluarga extends Authenticatable
{
    use SoftDeletes;

    protected $table = 'keluarga';

    protected $keyType = 'string';

    public $incrementing = false;

    protected $hidden = [
        'pin_hash',
        'failed_pin_attempts',
        'locked_until',
    ];

    public function getAuthIdentifierName(): string
    {
        return 'nomor_hp';
    }

    public function getAuthPasswordName(): string
    {
        return 'pin_hash';
    }

    protected function casts(): array
    {
        return [
            'dibuat_oleh_amil' => 'boolean',
            'locked_until' => 'immutable_datetime',
        ];
    }
}
