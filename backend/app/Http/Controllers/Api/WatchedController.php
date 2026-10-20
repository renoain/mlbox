<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreWatchedRequest;
use App\Http\Resources\WatchedResource;
use App\Http\Traits\ApiResponse;
use App\Models\Watched;
use App\Services\ActivityLogger;
use App\Services\WatchlistService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WatchedController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->watcheds()->with('movie.genres')->latest('watched_at')->get();

        return $this->success(WatchedResource::collection($items)->resolve($request));
    }

    public function store(
        StoreWatchedRequest $request,
        ActivityLogger $logger,
        WatchlistService $watchlists,
    ): JsonResponse {
        $movieId = $request->integer('movie_id');

        if (Watched::where('user_id', $request->user()->id)->where('movie_id', $movieId)->exists()) {
            return $this->failure('Film sudah tercatat sebagai watched.', 409);
        }

        $watched = Watched::create([
            'user_id' => $request->user()->id,
            'movie_id' => $movieId,
            'watched_at' => $request->date('watched_at') ?? now()->toDateString(),
        ]);

        $logger->log($request->user()->id, ActivityLogger::TYPE_WATCHED, $watched->id, [
            'movie_id' => $movieId,
            'watched_at' => $watched->watched_at->toDateString(),
        ]);

        // Film yang sudah ditonton keluar dari watchlist.
        $watchlists->remove($request->user()->id, $movieId);

        return $this->success(new WatchedResource($watched->load('movie.genres')), null, 201);
    }

    public function update(Request $request, int $movieId): JsonResponse
    {
        $watched = $request->user()->watcheds()->where('movie_id', $movieId)->first();

        if ($watched === null) {
            return $this->failure('Film tidak tercatat sebagai watched.', 404);
        }

        $watched->update($request->validate([
            'watched_at' => ['required', 'date', 'before_or_equal:today'],
        ]));

        return $this->success(new WatchedResource($watched->fresh('movie.genres')));
    }

    public function destroy(Request $request, int $movieId): JsonResponse
    {
        $deleted = $request->user()->watcheds()->where('movie_id', $movieId)->delete();

        if ($deleted === 0) {
            return $this->failure('Film tidak tercatat sebagai watched.', 404);
        }

        return $this->success(null);
    }
}
