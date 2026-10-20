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
     * Agregat untuk satu film.
     *
     * @return array{average_rating: float|null, review_count: int, watched_count: int, watchlist_count: int}
     */
    public function statsFor(int $movieId): array
    {
        return $this->statsMap([$movieId])[$movieId] ?? self::emptyStats();
    }

    /**
     * Agregat untuk sekumpulan film, dihitung dengan satu query per tabel.
     *
     * Tiap tabel dihitung terpisah supaya tidak terjadi perkalian baris.
     * Kalau reviews dan watcheds di-join dalam satu query, `count()` akan
     * menghitung kombinasi baris sehingga angkanya salah.
     *
     * @param  array<int, int>|null  $movieIds  null berarti semua film.
     * @return array<int, array{average_rating: float|null, review_count: int, watched_count: int, watchlist_count: int}>
     */
    public function statsMap(?array $movieIds = null): array
    {
        $map = [];

        // Film tanpa review/watchlist/watch tetap dapat entri dengan nilai
        // nol, supaya pemanggil tidak perlu memeriksa keberadaan kuncinya.
        foreach ($movieIds ?? [] as $movieId) {
            $map[(int) $movieId] = self::emptyStats();
        }

        $reviews = Review::query()
            ->selectRaw('movie_id, AVG(rating) AS avg_rating, COUNT(*) AS review_count')
            ->when($movieIds !== null, fn ($query) => $query->whereIn('movie_id', $movieIds))
            ->groupBy('movie_id')
            ->get();

        foreach ($reviews as $row) {
            // `array_merge` (bukan `+`) supaya angka asli dari database yang
            // menang, bukan nilai nol bawaan.
            $map[(int) $row->movie_id] = array_merge(self::emptyStats(), [
                'average_rating' => $row->avg_rating === null ? null : (float) round((float) $row->avg_rating, 2),
                'review_count' => (int) $row->review_count,
            ]);
        }

        $watched = Watched::query()
            ->selectRaw('movie_id, COUNT(*) AS watched_count')
            ->when($movieIds !== null, fn ($query) => $query->whereIn('movie_id', $movieIds))
            ->groupBy('movie_id')
            ->pluck('watched_count', 'movie_id');

        foreach ($watched as $movieId => $count) {
            $map[(int) $movieId]['watched_count'] = (int) $count;
        }

        $watchlisted = Watchlist::query()
            ->selectRaw('movie_id, COUNT(*) AS watchlist_count')
            ->when($movieIds !== null, fn ($query) => $query->whereIn('movie_id', $movieIds))
            ->groupBy('movie_id')
            ->pluck('watchlist_count', 'movie_id');

        foreach ($watchlisted as $movieId => $count) {
            $map[(int) $movieId]['watchlist_count'] = (int) $count;
        }

        return array_map(
            static fn (array $stats): array => array_merge(self::emptyStats(), $stats),
            $map,
        );
    }

    /**
     * Nilai nol untuk film yang belum punya review/watchlist/watch.
     *
     * @return array{average_rating: float|null, review_count: int, watched_count: int, watchlist_count: int}
     */
    public static function emptyStats(): array
    {
        return [
            'average_rating' => null,
            'review_count' => 0,
            'watched_count' => 0,
            'watchlist_count' => 0,
        ];
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