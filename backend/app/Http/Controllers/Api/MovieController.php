<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\RateMovieRequest;
use App\Http\Resources\MovieResource;
use App\Http\Traits\ApiResponse;
use App\Models\Genre;
use App\Models\Movie;
use App\Models\Review;
use App\Services\ActivityLogger;
use App\Services\MovieStatsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MovieController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly MovieStatsService $stats)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $query = Movie::query()->with('genres');

        if ($request->filled('q')) {
            $query->where('title', 'like', '%'.$request->string('q')->toString().'%');
        }

        if ($request->filled('genre_id')) {
            $query->whereHas('genres', fn ($q) => $q->where('genres.id', $request->integer('genre_id')));
        }

        match ($request->string('sort')->toString()) {
            'title' => $query->orderBy('title'),
            'release_date' => $query->orderByDesc('release_date'),
            'rating' => $query->withAvg('reviews', 'rating')->orderByDesc('reviews_avg_rating'),
            default => $query->orderByDesc('created_at'),
        };

        $paginator = $query->paginate(20)->withQueryString();

        return $this->success(
            MovieResource::collection($paginator->getCollection())->resolve($request),
            [
                'page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        );
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $movie = Movie::with('genres')->find($id);

        if ($movie === null) {
            return $this->failure('Film tidak ditemukan.', 404);
        }

        $user = $request->user();

        // Catatan: JsonResource::resolve() tidak menggabungkan additional() pada
        // versi Laravel ini, jadi angka agregat di-merge eksplisit di sini.
        $payload = array_merge(
            MovieResource::make($movie)->resolve($request),
            [
                'average_rating' => $this->stats->getAverageRating($movie->id),
                'review_count' => $this->stats->getReviewCount($movie->id),
                'watched_count' => $this->stats->getWatchedCount($movie->id),
                'watchlist_count' => $this->stats->getWatchlistCount($movie->id),
                'like_count' => $movie->likes()->count(),
                'liked' => $user !== null && $movie->likes()->where('user_id', $user->id)->exists(),
                'in_watchlist' => $user !== null && $movie->watchlists()->where('user_id', $user->id)->exists(),
                'watched_at' => $user === null
                    ? null
                    : $movie->watcheds()->where('user_id', $user->id)->value('watched_at'),
                'diary_entry_id' => $user === null
                    ? null
                    : $movie->diaryEntries()->where('user_id', $user->id)->value('id'),
            ],
        );

        return $this->success($payload);
    }

    /**
     * Simpan rating bintang saja, tanpa entri diary.
     */
    public function rate(RateMovieRequest $request, int $id, ActivityLogger $logger): JsonResponse
    {
        $movie = Movie::find($id);

        if ($movie === null) {
            return $this->failure('Film tidak ditemukan.', 404);
        }

        $rating = $request->integer('rating');

        $review = Review::firstOrNew([
            'user_id' => $request->user()->id,
            'movie_id' => $id,
        ]);
        $review->rating = $rating;
        $review->save();

        $logger->log($request->user()->id, ActivityLogger::TYPE_RATED, $review->id, [
            'movie_id' => $id,
            'rating' => $rating,
        ]);

        // 201 untuk rating pertama, 200 saat nilai diperbarui.
        $status = $review->wasRecentlyCreated ? 201 : 200;

        return $this->success([
            'movie_id' => $id,
            'review_id' => $review->id,
            'rating' => $review->rating,
        ], null, $status);
    }

    /**
     * Hapus rating bintang; teks review tetap tersimpan jika ada.
     */
    public function unrate(Request $request, int $id): JsonResponse
    {
        $review = Review::where('user_id', $request->user()->id)
            ->where('movie_id', $id)
            ->first();

        if ($review === null || $review->rating === null) {
            return $this->failure('Film ini belum diberi rating.', 404);
        }

        if ($review->content === null) {
            $review->delete();
        } else {
            $review->update(['rating' => null]);
        }

        return $this->success([
            'movie_id' => $id,
            'rating' => null,
        ]);
    }
}
