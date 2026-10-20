<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreLogRequest;
use App\Http\Traits\ApiResponse;
use App\Models\DiaryEntry;
use App\Models\Review;
use App\Models\Tag;
use App\Models\Watched;
use App\Services\ActivityLogger;
use App\Services\WatchlistService;
use App\Services\WatchLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class LogController extends Controller
{
    use ApiResponse;

    public function store(
        StoreLogRequest $request,
        ActivityLogger $logger,
        WatchlistService $watchlists,
        WatchLogService $log,
    ): JsonResponse {
        $userId = $request->user()->id;
        $movieId = $request->integer('movie_id');

        if (Watched::where('user_id', $userId)->where('movie_id', $movieId)->exists()) {
            return $this->failure('Film ini sudah tercatat sebagai watched.', 409);
        }

        $watchedAt = ($request->date('watched_at') ?? now())->toDateString();

        // Unique constraint mengizinkan log berulang hanya pada tanggal berbeda.
        $diaryExists = DiaryEntry::where('user_id', $userId)
            ->where('movie_id', $movieId)
            ->whereDate('watched_date', $watchedAt)
            ->exists();

        if ($diaryExists) {
            return $this->failure('Entri diary untuk tanggal ini sudah ada.', 409);
        }

        $result = DB::transaction(function () use ($request, $userId, $movieId, $watchedAt, $logger, $watchlists, $log): array {
            // Baris `watched` dan entri log dibuat bersamaan supaya keduanya
            // selalu sinkron.
            $created = $log->markWatched($userId, $movieId, $watchedAt, $request->input('note'));
            $watched = $created['watched'];
            $entry = $created['entry'];

            $logger->log($userId, ActivityLogger::TYPE_WATCHED, $watched->id, [
                'movie_id' => $movieId,
                'watched_at' => $watchedAt,
            ]);

            // Film yang sudah di-log keluar dari watchlist.
            $watchlists->remove($userId, $movieId);

            $tags = collect();

            foreach ($request->input('tags', []) as $name) {
                $tag = Tag::firstOrCreate(
                    ['user_id' => $userId, 'name' => $name],
                );
                $entry->tags()->syncWithoutDetaching([$tag->id]);
                $tags->push($tag);
            }

            $review = null;

            if ($request->filled('rating')) {
                // Satu user hanya boleh punya satu review per film. Kalau
                // rating-nya sudah ada (mis. dari `POST /movies/{id}/rate`),
                // review-nya diperbarui, bukan dibuat baru.
                $review = Review::firstOrNew([
                    'user_id' => $userId,
                    'movie_id' => $movieId,
                ]);

                $review->rating = $request->integer('rating');

                if ($request->has('content')) {
                    $review->content = $request->input('content');
                }

                $review->save();

                $logger->log($userId, ActivityLogger::TYPE_RATED, $review->id, [
                    'movie_id' => $movieId,
                    'rating' => $review->rating,
                ]);

                if ($review->content !== null) {
                    $logger->log($userId, ActivityLogger::TYPE_REVIEWED, $review->id, [
                        'movie_id' => $movieId,
                        'excerpt' => mb_substr((string) $review->content, 0, 120),
                    ]);
                }
            }

            return [
                'watched' => [
                    'id' => $watched->id,
                    'movie_id' => $movieId,
                    'watched_at' => $watchedAt,
                    'note' => $request->input('note'),
                ],
                'diary_entry' => ['id' => $entry->id],
                'review' => $review === null ? null : [
                    'id' => $review->id,
                    'rating' => $review->rating,
                    'content' => $review->content,
                ],
                'tags' => $tags->map(fn (Tag $tag) => ['id' => $tag->id, 'name' => $tag->name])->all(),
            ];
        });

        return $this->success($result, null, 201);
    }
}
