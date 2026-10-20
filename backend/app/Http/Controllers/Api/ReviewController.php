<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreReviewRequest;
use App\Http\Requests\UpdateReviewRequest;
use App\Http\Resources\ReviewResource;
use App\Http\Traits\ApiResponse;
use App\Models\Review;
use App\Services\ActivityLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $reviews = $request->user()->reviews()
            ->with(['movie.genres', 'likes' => fn ($q) => $q->where('user_id', $request->user()->id)])
            ->withCount('likes')
            ->latest()
            ->get();

        return $this->success(ReviewResource::collection($reviews)->resolve($request));
    }

    public function store(StoreReviewRequest $request, ActivityLogger $logger): JsonResponse
    {
        $movieId = $request->integer('movie_id');

        $exists = Review::where('user_id', $request->user()->id)->where('movie_id', $movieId)->exists();

        if ($exists) {
            return $this->failure('Anda sudah punya review untuk film ini. Gunakan endpoint ubah.', 409);
        }

        $review = Review::create([
            'user_id' => $request->user()->id,
            'movie_id' => $movieId,
            'rating' => $request->integer('rating'),
            'content' => $request->input('content'),
        ]);

        $logger->log($request->user()->id, ActivityLogger::TYPE_RATED, $review->id, [
            'movie_id' => $movieId,
            'rating' => $review->rating,
        ]);

        if ($review->content !== null) {
            $logger->log($request->user()->id, ActivityLogger::TYPE_REVIEWED, $review->id, [
                'movie_id' => $movieId,
                'excerpt' => mb_substr((string) $review->content, 0, 120),
            ]);
        }

        return $this->success(new ReviewResource($review->load('movie.genres')), null, 201);
    }

    public function update(UpdateReviewRequest $request, int $id): JsonResponse
    {
        $review = $request->user()->reviews()->find($id);

        if ($review === null) {
            return $this->failure('Review tidak ditemukan.', 404);
        }

        $review->update($request->validated());

        return $this->success(new ReviewResource($review->fresh('movie.genres')));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $deleted = $request->user()->reviews()->where('id', $id)->delete();

        if ($deleted === 0) {
            return $this->failure('Review tidak ditemukan.', 404);
        }

        return $this->success(null);
    }
}
