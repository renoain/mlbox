<?php

declare(strict_types=1);

// Konfigurasi CORS untuk API. Production wajib mengganti
// allowed_origins ke domain spesifik, jangan pakai wildcard.
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
