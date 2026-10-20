<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreWatchlistRequest;
use App\Http\Resources\WatchlistResource;
use App\Http\Traits\ApiResponse;
use App\Models\Watchlist;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WatchlistController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->watchlists()->with('movie.genres')->latest()->get();

        return $this->success(WatchlistResource::collection($items)->resolve($request));
    }

    public function store(StoreWatchlistRequest $request): JsonResponse
    {
        $exists = Watchlist::where('user_id', $request->user()->id)
            ->where('movie_id', $request->integer('movie_id'))
            ->exists();

        if ($exists) {
            return $this->failure('Film sudah ada di watchlist.', 409);
        }

        $item = Watchlist::create([
            'user_id' => $request->user()->id,
            'movie_id' => $request->integer('movie_id'),
        ]);

        return $this->success(new WatchlistResource($item->load('movie.genres')), null, 201);
    }

    public function destroy(Request $request, int $movieId): JsonResponse
    {
        $deleted = Watchlist::where('user_id', $request->user()->id)
            ->where('movie_id', $movieId)
            ->delete();

        if ($deleted === 0) {
            return $this->failure('Film tidak ada di watchlist.', 404);
        }

        return $this->success(null);
    }
}
