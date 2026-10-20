<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreCommentRequest;
use App\Http\Resources\CommentResource;
use App\Http\Traits\ApiResponse;
use App\Models\Comment;
use App\Models\Notification;
use App\Models\Review;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

// Endpoint komentar pada review.
class CommentController extends Controller
{
    use ApiResponse;

    public function index(int $reviewId): JsonResponse
    {
        $review = Review::find($reviewId);

        if ($review === null) {
            return $this->failure('Review tidak ditemukan.', 404);
        }

        $comments = $review->comments()->with('user')->orderBy('created_at')->get();

        return $this->success(CommentResource::collection($comments)->resolve());
    }

    public function store(
        StoreCommentRequest $request,
        int $reviewId,
        NotificationService $notifications,
    ): JsonResponse {
        $review = Review::find($reviewId);

        if ($review === null) {
            return $this->failure('Review tidak ditemukan.', 404);
        }

        $comment = Comment::create([
            'review_id' => $reviewId,
            'user_id' => $request->user()->id,
            'content' => $request->string('content')->toString(),
        ]);

        $notifications->notify(
            $review->user_id,
            $request->user()->id,
            Notification::TYPE_COMMENT_REVIEW,
            $comment->id,
        );

        return $this->success(
            new CommentResource($comment->load('user')),
            null,
            201,
        );
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $comment = Comment::find($id);

        if ($comment === null) {
            return $this->failure('Komentar tidak ditemukan.', 404);
        }

        if ($comment->user_id !== $request->user()->id) {
            return $this->failure('Anda hanya dapat menghapus komentar sendiri.', 403);
        }

        $comment->delete();

        return $this->success(['id' => $id, 'deleted' => true]);
    }
}
