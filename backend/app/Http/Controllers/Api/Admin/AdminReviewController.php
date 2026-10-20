<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Resources\ReviewResource;
use App\Http\Traits\ApiResponse;
use App\Models\Review;
use App\Services\AdminAuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminReviewController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Review::query()->with(['movie', 'user']);

        if ($request->filled('q')) {
            $query->where('content', 'like', '%'.$request->string('q')->toString().'%');
        }

        if ($request->filled('movie_id')) {
            $query->where('movie_id', $request->integer('movie_id'));
        }

        if ($request->filled('rating')) {
            $query->where('rating', $request->integer('rating'));
        }

        $reviews = $query->latest()->paginate(20)->withQueryString();

        return $this->success(
            ReviewResource::collection($reviews->getCollection())->resolve($request),
            ['page' => $reviews->currentPage(), 'total' => $reviews->total()],
        );
    }

    public function destroy(Request $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $review = Review::with('user')->find($id);

        if ($review === null) {
            return $this->failure('Review tidak ditemukan.', 404);
        }

        $review->delete();

        $audit->log($request->user()->id, 'delete', 'review', $id, [
            'user_name' => $review->user->name,
            'movie_id' => $review->movie_id,
            'rating' => $review->rating,
        ]);

        return $this->success(null);
    }
}
