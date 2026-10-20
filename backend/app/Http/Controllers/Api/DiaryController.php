<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreDiaryRequest;
use App\Http\Requests\UpdateDiaryRequest;
use App\Http\Resources\DiaryResource;
use App\Http\Resources\ReviewResource;
use App\Http\Traits\ApiResponse;
use App\Models\DiaryEntry;
use App\Services\WatchlistService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DiaryController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = $request->user()->diaryEntries()
            ->with(['movie.genres', 'tags', 'movie.reviews' => fn ($q) => $q->where('user_id', $request->user()->id)]);

        if ($request->filled('from')) {
            $query->whereDate('watched_date', '>=', $request->date('from'));
        }

        if ($request->filled('to')) {
            $query->whereDate('watched_date', '<=', $request->date('to'));
        }

        if ($request->filled('tag_id')) {
            $query->whereHas('tags', fn ($q) => $q->where('tags.id', $request->integer('tag_id')));
        }

        $entries = $query->orderByDesc('watched_date')->get();

        $grouped = $entries
            ->groupBy(fn (DiaryEntry $entry) => $entry->watched_date->toDateString())
            ->map(fn ($items, string $date) => [
                'watched_date' => $date,
                'items' => $items->map(function (DiaryEntry $entry) use ($request): array {
                    $review = $entry->movie->reviews->first();

                    return [
                        'id' => $entry->id,
                        'movie' => \App\Http\Resources\MovieResource::make($entry->movie)->resolve($request),
                        'note' => $entry->note,
                        'tags' => TagResourceLite::for($entry),
                        'rating' => $review?->rating,
                        'content' => $review?->content,
                    ];
                })->all(),
            ]);

        return $this->success($grouped->values()->all());
    }

    public function store(StoreDiaryRequest $request, WatchlistService $watchlists): JsonResponse
    {
        $userId = $request->user()->id;
        $movieId = $request->integer('movie_id');
        $watchedDate = ($request->date('watched_date') ?? now())->toDateString();

        // Satu film boleh punya banyak entri selama tanggalnya berbeda.
        $exists = DiaryEntry::where('user_id', $userId)
            ->where('movie_id', $movieId)
            ->whereDate('watched_date', $watchedDate)
            ->exists();

        if ($exists) {
            return $this->failure('Entri diary untuk tanggal ini sudah ada.', 409);
        }

        $entry = DiaryEntry::create([
            'user_id' => $userId,
            'movie_id' => $movieId,
            'watched_date' => $watchedDate,
            'note' => $request->input('note'),
        ]);

        // Film yang sudah di-log keluar dari watchlist.
        $watchlists->remove($userId, $movieId);

        return $this->success(new DiaryResource($entry->load(['movie.genres', 'tags'])), null, 201);
    }

    public function update(UpdateDiaryRequest $request, int $id): JsonResponse
    {
        $entry = $request->user()->diaryEntries()->find($id);

        if ($entry === null) {
            return $this->failure('Entri diary tidak ditemukan.', 404);
        }

        $entry->update($request->validated());

        return $this->success(new DiaryResource($entry->fresh(['movie.genres', 'tags'])));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $deleted = $request->user()->diaryEntries()->where('id', $id)->delete();

        if ($deleted === 0) {
            return $this->failure('Entri diary tidak ditemukan.', 404);
        }

        return $this->success(null);
    }
}

/**
 * Bentuk ringkas tag untuk response diary yang dikelompokkan per tanggal.
 */
final class TagResourceLite
{
    /**
     * @return array<int, array{id: int, name: string}>
     */
    public static function for(DiaryEntry $entry): array
    {
        return $entry->tags
            ->map(fn ($tag) => ['id' => $tag->id, 'name' => $tag->name])
            ->all();
    }
}
