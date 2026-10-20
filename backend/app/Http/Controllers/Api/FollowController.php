<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\UserResource;
use App\Http\Traits\ApiResponse;
use App\Models\Follow;
use App\Models\Notification;
use App\Models\User;
use App\Services\ActivityLogger;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

// Endpoint follow dan unfollow antar user.
class FollowController extends Controller
{
    use ApiResponse;

    public function store(
        Request $request,
        int $userId,
        ActivityLogger $logger,
        NotificationService $notifications,
    ): JsonResponse {
        $me = $request->user();

        if ($userId === $me->id) {
            return $this->failure('Anda tidak dapat mengikuti diri sendiri.', 422);
        }

        $target = User::find($userId);

        if ($target === null) {
            return $this->failure('User tidak ditemukan.', 404);
        }

        if (Follow::where('follower_id', $me->id)->where('following_id', $userId)->exists()) {
            return $this->failure('Anda sudah mengikuti user ini.', 409);
        }

        $follow = Follow::create(['follower_id' => $me->id, 'following_id' => $userId]);

        $logger->log($me->id, ActivityLogger::TYPE_FOLLOWED, $follow->id, [
            'following_name' => $target->name,
        ]);

        $notifications->notify($userId, $me->id, Notification::TYPE_FOLLOW, $follow->id);

        return $this->success([
            'user_id' => $userId,
            'is_following' => true,
            'follower_count' => $target->followers()->count(),
        ]);
    }

    public function destroy(Request $request, int $userId): JsonResponse
    {
        $deleted = Follow::where('follower_id', $request->user()->id)
            ->where('following_id', $userId)
            ->delete();

        if ($deleted === 0) {
            return $this->failure('Anda tidak mengikuti user ini.', 404);
        }

        return $this->success([
            'user_id' => $userId,
            'is_following' => false,
            'follower_count' => User::whereKey($userId)->first()?->followers()->count() ?? 0,
        ]);
    }

    public function followers(Request $request): JsonResponse
    {
        $users = $request->user()->followers()
            ->withPivot('created_at')
            ->orderByDesc('follows.created_at')
            ->get();

        return $this->success($this->mapUsers($request, $users));
    }

    public function following(Request $request): JsonResponse
    {
        $users = $request->user()->following()
            ->withPivot('created_at')
            ->orderByDesc('follows.created_at')
            ->get();

        return $this->success($this->mapUsers($request, $users));
    }

    /**
     * @param  \Illuminate\Support\Collection<int, User>  $users
     * @return array<int, array<string, mixed>>
     */
    private function mapUsers(Request $request, $users): array
    {
        $meId = $request->user()->id;

        return $users->map(fn (User $user) => [
            'id' => $user->id,
            'name' => $user->name,
            'is_following' => $user->following()->where('users.id', $meId)->exists(),
            'followed_at' => $user->pivot->created_at,
        ])->all();
    }
}
