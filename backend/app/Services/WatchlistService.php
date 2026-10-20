<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Watchlist;

/**
 * Aturan transisi watchlist: film yang ditonton keluar dari watchlist.
 */
class WatchlistService
{
    public function remove(int $userId, int $movieId): void
    {
        Watchlist::where('user_id', $userId)
            ->where('movie_id', $movieId)
            ->delete();
    }
}
