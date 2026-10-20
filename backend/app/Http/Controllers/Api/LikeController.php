<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreLikeRequest;
use App\Http\Resources\LikeResource;
use App\Http\Traits\ApiResponse;
use App\Models\Like;
use App\Models\Movie;
use App\Models\MovieList;
use App\Models\Notification;
use App\Models\Review;
use App\Services\ActivityLogger;
use App\Services\NotificationService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

// Endpoint like polymorphic untuk film, review, dan list.
class LikeController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->likes()->latest()->get();

        return $this->success(LikeResource::collection($items)->resolve($request));
    }

    public function show(Request $request, int $movieId): JsonResponse
    {
        return $this->success([
            'movie_id' => $movieId,
            'liked' => $this->likedBy($request->user()->id, Movie::class, $movieId),
            'likes_count' => $this->countLikes(Movie::class, $movieId),
        ]);
    }

    public function store(
        StoreLikeRequest $request,
        ActivityLogger $logger,
        NotificationService $notifications,
    ): JsonResponse {
        $user = $request->user();
        $type = $request->string('likeable_type')->toString();
        $targetId = $request->integer('likeable_id');

        $target = $this->resolveTarget($type, $targetId);

        if ($target === null) {
            return $this->failure('Objek tidak ditemukan.', 404);
        }

        if ($this->likedBy($user->id, $type, $targetId)) {
            return $this->failure('Anda sudah menyukai objek ini.', 409);
        }

        $like = Like::create([
            'user_id' => $user->id,
            'likeable_id' => $targetId,
            'likeable_type' => $type,
        ]);

        $logger->log($user->id, ActivityLogger::TYPE_LIKED, $like->id, [
            'likeable_type' => $this->shortType($type),
            'likeable_id' => $targetId,
        ]);

        $this->notifyOwner($notifications, $user->id, $type, $target);

        return $this->success([
            'likeable_id' => $targetId,
            'likeable_type' => $type,
            'liked' => true,
            'likes_count' => $this->countLikes($type, $targetId),
        ], null, 201);
    }

    public function destroy(StoreLikeRequest $request): JsonResponse
    {
        $user = $request->user();
        $type = $request->string('likeable_type')->toString();
        $targetId = $request->integer('likeable_id');

        $deleted = Like::where('user_id', $user->id)
            ->where('likeable_type', $type)
            ->where('likeable_id', $targetId)
            ->delete();

        if ($deleted === 0) {
            return $this->failure('Anda belum menyukai objek ini.', 404);
        }

        return $this->success([
            'likeable_id' => $targetId,
            'likeable_type' => $type,
            'liked' => false,
            'likes_count' => $this->countLikes($type, $targetId),
        ]);
    }

    /**
     * Cari target like berdasarkan tipe yang sudah divalidasi FormRequest.
     */
    private function resolveTarget(string $type, int $targetId): ?Model
    {
        return match ($type) {
            Movie::class => Movie::find($targetId),
            Review::class => Review::find($targetId),
            MovieList::class => MovieList::find($targetId),
            default => null,
        };
    }

    /**
     * Notifikasi hanya untuk like review dan like list, bukan like film.
     */
    private function notifyOwner(NotificationService $notifications, int $actorId, string $type, Model $target): void
    {
        $notificationType = match ($type) {
            Review::class => Notification::TYPE_LIKE_REVIEW,
            MovieList::class => Notification::TYPE_LIKE_LIST,
            default => null,
        };

        if ($notificationType !== null) {
            $notifications->notify((int) $target->user_id, $actorId, $notificationType, (int) $target->id);
        }
    }

    private function likedBy(int $userId, string $type, int $targetId): bool
    {
        return Like::where('user_id', $userId)
            ->where('likeable_type', $type)
            ->where('likeable_id', $targetId)
            ->exists();
    }

    private function countLikes(string $type, int $targetId): int
    {
        return Like::where('likeable_type', $type)
            ->where('likeable_id', $targetId)
            ->count();
    }

    private function shortType(string $type): string
    {
        return match ($type) {
            Review::class => 'review',
            MovieList::class => 'list',
            default => 'movie',
        };
    }
}
