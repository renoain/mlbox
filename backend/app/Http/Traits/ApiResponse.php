<?php

declare(strict_types=1);

namespace App\Http\Traits;

/**
 * Format respons JSON yang konsisten untuk seluruh endpoint.
 */
trait ApiResponse
{
    /**
     * Respons sukses.
     *
     * @param  array<string, mixed>  $meta  kunci tambahan seperti paginasi
     */
    protected function success(mixed $data = null, ?array $meta = null, int $status = 200): \Illuminate\Http\JsonResponse
    {
        $payload = ['success' => true, 'data' => $data];

        if ($meta !== null && $meta !== []) {
            $payload['meta'] = $meta;
        }

        return response()->json($payload, $status);
    }

    /**
     * Respons error. Detail teknis tidak pernah masuk ke message.
     *
     * @param  array<string, mixed>  $errors
     */
    protected function failure(string $message, int $status = 400, array $errors = []): \Illuminate\Http\JsonResponse
    {
        $payload = ['success' => false, 'message' => $message];

        if ($errors !== []) {
            $payload['errors'] = $errors;
        }

        return response()->json($payload, $status);
    }
}