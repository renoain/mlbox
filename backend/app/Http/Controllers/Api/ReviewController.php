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
        // Relasi `user` harus di-eager-load, kalau tidak `user_name` di
        // payload akan kosong (fallback "Anonymous" di app).
        $reviews = $request->user()->reviews()
            ->with(['user', 'movie.genres', 'likes' => fn ($q) => $q->where('user_id', $request->user()->id)])
            ->withCount('likes')
            ->latest()
            ->get();

        return $this->success(ReviewResource::collection($reviews)->resolve($request));
    }

    public function store(StoreReviewRequest $request, ActivityLogger $logger): JsonResponse
    {
        $movieId = $request->integer('movie_id');

        // Satu user hanya boleh punya satu review per film.
        //
        // Kalau user sudah memberi rating bintang lewat
        // `POST /movies/{id}/rate`, baris review-nya sudah ada (rating saja,
        // tanpa teks). Menolak dengan 409 akan membuat alur "beri rating ->
        // tulis review" gagal, jadi baris yang ada diperbarui di sini.
        $review = Review::firstOrNew([
            'user_id' => $request->user()->id,
            'movie_id' => $movieId,
        ]);

        $isNew = ! $review->exists;

        $review->rating = $request->integer('rating');

        // Teks review hanya ditimpa kalau request benar-benar mengirim
        // `content`, supaya review yang sudah ada tidak ikut terhapus saat
        // user menyimpan review tanpa menulis apa pun.
        if ($request->has('content')) {
            $review->content = $request->input('content');
        }

        $review->save();
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

        return $this->success(
            new ReviewResource($review->load(['user', 'movie.genres'])),
            null,
            $isNew ? 201 : 200,
        );
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
