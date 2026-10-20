<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\NotificationResource;
use App\Http\Traits\ApiResponse;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

// Endpoint notifikasi milik user yang login.
class NotificationController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->notifications()
            ->with('actor')
            ->latest()
            ->get();

        return $this->success(NotificationResource::collection($items)->resolve());
    }

    public function markRead(Request $request, int $id): JsonResponse
    {
        $notification = $request->user()->notifications()->find($id);

        if ($notification === null) {
            return $this->failure('Notifikasi tidak ditemukan.', 404);
        }

        $notification->update(['is_read' => true]);

        return $this->success(new NotificationResource($notification->load('actor')));
    }

    public function markAllRead(Request $request): JsonResponse
    {
        $updated = $request->user()->notifications()
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return $this->success(['updated' => $updated]);
    }
}
