<?php

declare(strict_types=1);

return [
    /*
    | Konfigurasi tampilan Blade, termasuk lokasi compiled view.
    */

    'paths' => [
        resource_path('views'),
    ],

    'compiled' => env('VIEW_COMPILED_PATH', storage_path('framework/views')),
];
