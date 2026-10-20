<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Notification;

/**
 * Penulis baris ke tabel notifications untuk interaksi sosial.
 */
class NotificationService
{
    /**
     * Kirim notifikasi, kecuali pelaku sama dengan penerima.
     */
    public function notify(int $userId, int $actorId, string $type, int $referenceId): void
    {
        if ($userId === $actorId) {
            return;
        }

        Notification::create([
            'user_id' => $userId,
            'actor_id' => $actorId,
            'type' => $type,
            'reference_id' => $referenceId,
        ]);
    }
}
