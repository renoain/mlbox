<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

/**
 * Menyajikan berkas media (poster, backdrop) yang ada di
 * `storage/app/public` lewat route Laravel.
 *
 * Alasan file tidak disajikan langsung dari `/storage/...`: pada
 * `php artisan serve` (dan Apache/Nginx), berkas statis di `public/`
 * dilayani server tanpa melewati middleware Laravel, sehingga tidak
 * pernah mendapat header CORS. Flutter Web memuat gambar lewat XHR
 * sehingga browser memblokir gambar yang tidak punya header CORS.
 */
class MediaController extends Controller
{
    public function show(Request $request, string $path): BinaryFileResponse
    {
        $relative = str_replace('\\', '/', $path);

        // Cegah path traversal (mis. `../../.env`).
        if ($relative === '' || str_contains($relative, '..')) {
            abort(404, 'Media tidak ditemukan.');
        }

        $file = storage_path('app/public/'.ltrim($relative, '/'));
        $real = realpath($file);
        $root = realpath(storage_path('app/public'));

        if ($real === false || $root === false || ! str_starts_with($real, $root)) {
            abort(404, 'Media tidak ditemukan.');
        }

        if (! is_file($real)) {
            abort(404, 'Media tidak ditemukan.');
        }

        return response()->file($real, [
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }
}
