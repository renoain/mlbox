<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Movie;
use App\Models\Review;
use App\Models\Watched;
use App\Models\Watchlist;

/**
 * Menghitung angka agregat per film dari data user.
 *
 * Angka tidak disimpan di tabel movies supaya tidak bisa basi.
 */
class MovieStatsService
{
    public function getAverageRating(int $movieId): ?float
    {
        $average = Review::where('movie_id', $movieId)->avg('rating');

        return $average === null ? null : (float) round((float) $average, 2);
    }

    public function getReviewCount(int $movieId): int
    {
        return Review::where('movie_id', $movieId)->count();
    }

    public function getWatchedCount(int $movieId): int
    {
        return Watched::where('movie_id', $movieId)->count();
    }

    public function getWatchlistCount(int $movieId): int
    {
        return Watchlist::where('movie_id', $movieId)->count();
    }

    /**
     * Agregat untuk dipakai oleh HomeService.
     *
     * @return array<int, array{avg_rating: float|null, review_count: int}>
     */
    public function ratingMap(): array
    {
        $rows = Movie::query()
            ->leftJoin('reviews', 'reviews.movie_id', '=', 'movies.id')
            ->whereNull('movies.deleted_at')
            ->groupBy('movies.id')
            ->selectRaw('movies.id, avg(reviews.rating) as avg_rating, count(reviews.id) as review_count')
            ->get();

        $map = [];

        foreach ($rows as $row) {
            $map[(int) $row->id] = [
                'avg_rating' => $row->avg_rating === null ? null : (float) round((float) $row->avg_rating, 2),
                'review_count' => (int) $row->review_count,
            ];
        }

        return $map;
    }
}