<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\MovieResource;
use App\Http\Resources\UserResource;
use App\Http\Traits\ApiResponse;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PublicProfileController extends Controller
{
    use ApiResponse;

    public function show(Request $request, int $userId): JsonResponse
    {
        $user = User::with('favorites.movie.genres')->find($userId);

        if ($user === null) {
            return $this->failure('User tidak ditemukan.', 404);
        }

        $me = $request->user();

        return $this->success([
            ...(new UserResource($user))->resolve($request),
            'bio' => null,
            'is_following' => $user->following()->where('users.id', $me->id)->exists(),
            'is_self' => $user->id === $me->id,
            'follower_count' => $user->followers()->count(),
            'following_count' => $user->following()->count(),
            'stats' => [
                'total_watched' => $user->watcheds()->count(),
                'total_watchlist' => $user->watchlists()->count(),
                'total_reviews' => $user->reviews()->count(),
                'total_likes' => $user->likes()->count(),
            ],
            'favorites' => $user->favorites
                ->sortBy('position')
                ->values()
                ->map(fn ($favorite) => [
                    'position' => $favorite->position,
                    'movie_id' => $favorite->movie_id,
                    'movie' => MovieResource::make($favorite->movie)->resolve($request),
                ])
                ->all(),
        ]);
    }

    public function watched(Request $request, int $userId): JsonResponse
    {
        $user = User::find($userId);

        if ($user === null) {
            return $this->failure('User tidak ditemukan.', 404);
        }

        $query = $user->watcheds()->with('movie.genres')->latest('watched_at');

        if ($request->filled('from')) {
            $query->whereDate('watched_at', '>=', $request->date('from'));
        }

        if ($request->filled('to')) {
            $query->whereDate('watched_at', '<=', $request->date('to'));
        }

        return $this->success(
            \App\Http\Resources\WatchedResource::collection(
                $query->paginate(20)->withQueryString()
            ),
        );
    }
}
