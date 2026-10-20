<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Movie;
use Illuminate\Support\Facades\DB;

/**
 * Membangun enam section beranda dalam satu snapshot.
 */
class HomeService
{
    public const FEATURED_LIMIT = 5;
    public const SECTION_LIMIT = 10;

    public function __construct(
        private readonly MovieStatsService $stats,
    ) {
    }

    /**
     * @return array
     */
    public function getHomeData(): array
    {
        return DB::transaction(function (): array {
            $ratings = $this->stats->ratingMap();

            $featured = Movie::with('genres')
                ->where('is_featured', true)
                ->orderByDesc('created_at')
                ->limit(self::FEATURED_LIMIT)
                ->get();

            $latest = Movie::with('genres')
                ->orderByDesc('created_at')
                ->limit(self::SECTION_LIMIT)
                ->get();

            $topRated = Movie::with('genres')
                ->whereHas('reviews')
                ->get()
                ->sortByDesc(function (Movie $movie) use ($ratings): float {
                    return $ratings[$movie->id]['avg_rating'] ?? 0.0;
                })
                ->filter(function (Movie $movie) use ($ratings): bool {
                    return ($ratings[$movie->id]['review_count'] ?? 0) > 0;
                })
                ->take(self::SECTION_LIMIT)
                ->values();

            $mostWatched = Movie::with('genres')
                ->withCount('watcheds')
                ->orderByDesc('watcheds_count')
                ->limit(self::SECTION_LIMIT)
                ->get();

            $mostWatchlisted = Movie::with('genres')
                ->withCount('watchlists')
                ->orderByDesc('watchlists_count')
                ->limit(self::SECTION_LIMIT)
                ->get();

            $explore = Movie::with('genres')
                ->inRandomOrder()
                ->limit(self::SECTION_LIMIT)
                ->get();

            return [
                'featured' => $featured,
                'latest' => $latest,
                'top_rated' => $topRated,
                'most_watched' => $mostWatched,
                'most_watchlisted' => $mostWatchlisted,
                'explore' => $explore,
            ];
        }, 3);
    }
}