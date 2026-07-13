<?php

namespace App\Support\Environment;

use RuntimeException;

final class ProductionEnvironmentGuard
{
    /**
     * @param  array<string, bool>  $requirements
     */
    public function validate(array $requirements): void
    {
        $invalidKeys = array_keys(array_filter(
            $requirements,
            static fn (bool $isValid): bool => ! $isValid,
        ));

        if ($invalidKeys === []) {
            return;
        }

        throw new RuntimeException(sprintf(
            'Konfigurasi production tidak aman: %s.',
            implode(', ', $invalidKeys),
        ));
    }
}
