<?php

declare(strict_types=1);

// Konfigurasi CORS untuk API. Production wajib mengganti
// allowed_origins ke domain spesifik, jangan pakai wildcard.
return [
    // 'storage/*' wajib karena Flutter Web memuat poster lewat XHR:
    // tanpa header CORS, browser memblokir gambar (broken image).
    'paths' => ['api/*', 'storage/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
