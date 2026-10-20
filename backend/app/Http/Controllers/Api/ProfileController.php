<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\UserResource;
use App\Http\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    use ApiResponse;

    public function show(Request $request): JsonResponse
    {
        return $this->success(new UserResource($request->user()));
    }

    public function stats(Request $request): JsonResponse
    {
        $user = $request->user();

        return $this->success([
            'total_watched' => $user->watcheds()->count(),
            'total_watchlist' => $user->watchlists()->count(),
            'total_diary' => $user->diaryEntries()->count(),
            'total_reviews' => $user->reviews()->count(),
            'average_rating' => round((float) ($user->reviews()->avg('rating') ?? 0), 1),
            'total_likes' => $user->likes()->count(),
            'total_lists' => $user->lists()->count(),
            'total_followers' => $user->followers()->count(),
            'total_following' => $user->following()->count(),
        ]);
    }

    public function reviews(Request $request): JsonResponse
    {
        $query = $request->user()->reviews()
            ->with(['movie.genres', 'likes' => fn ($q) => $q->where('user_id', $request->user()->id)])
            ->withCount('likes');

        match ($request->string('sort')->toString()) {
            'rating' => $query->orderByDesc('rating'),
            default => $query->latest(),
        };

        return $this->success(
            \App\Http\Resources\ReviewResource::collection(
                $query->paginate(20)->withQueryString()
            ),
        );
    }
}
