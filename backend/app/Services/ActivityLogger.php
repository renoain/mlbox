<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Activity;

/**
 * Satu-satunya kelas yang menulis ke tabel activities.
 *
 * Tindakan admin tidak dicatat di sini supaya tidak bocor ke feed user.
 */
class ActivityLogger
{
    public const TYPE_WATCHED = 'watched';
    public const TYPE_RATED = 'rated';
    public const TYPE_REVIEWED = 'reviewed';
    public const TYPE_LIKED = 'liked';
    public const TYPE_LIST_CREATED = 'list_created';
    public const TYPE_FOLLOWED = 'followed';

    /**
     * @param  array<string, mixed>  $metadata  konteks per jenis aktivitas
     */
    public function log(
        int $userId,
        string $type,
        ?int $referenceId = null,
        array $metadata = [],
    ): void {
        Activity::create([
            'user_id' => $userId,
            'type' => $type,
            'reference_id' => $referenceId,
            'metadata' => $metadata === [] ? null : $metadata,
        ]);
    }
}