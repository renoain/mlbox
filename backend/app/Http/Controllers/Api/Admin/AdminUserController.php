<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Resources\ActivityResource;
use App\Http\Resources\UserResource;
use App\Http\Requests\Admin\UpdateUserRoleRequest;
use App\Http\Traits\ApiResponse;
use App\Models\User;
use App\Services\AdminAuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminUserController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = User::query()->withCount(['watchlists', 'watcheds']);

        if ($request->filled('q')) {
            $term = '%'.$request->string('q')->toString().'%';
            $query->where(fn ($q) => $q->where('name', 'like', $term)->orWhere('email', 'like', $term));
        }

        if ($request->filled('role')) {
            $query->where('role', $request->string('role')->toString());
        }

        $users = $query->orderBy('name')->paginate(20)->withQueryString();

        return $this->success(
            $users->getCollection()->map(fn (User $user) => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'movie_count' => $user->watchlists_count + $user->watcheds_count,
                'joined_at' => $user->created_at?->toIso8601String(),
            ])->all(),
            [
                'page' => $users->currentPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        );
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $user = User::find($id);

        if ($user === null) {
            return $this->failure('User tidak ditemukan.', 404);
        }

        return $this->success([
            ...(new UserResource($user))->resolve($request),
            'is_self' => $user->id === $request->user()->id,
            'stats' => [
                'total_watched' => $user->watcheds()->count(),
                'total_watchlist' => $user->watchlists()->count(),
                'total_reviews' => $user->reviews()->count(),
                'total_lists' => $user->lists()->count(),
                'total_likes' => $user->likes()->count(),
            ],
            'recent_activity' => ActivityResource::collection(
                $user->activities()->latest()->limit(10)->get()
            )->resolve($request),
        ]);
    }

    public function updateRole(UpdateUserRoleRequest $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $user = User::find($id);

        if ($user === null) {
            return $this->failure('User tidak ditemukan.', 404);
        }

        $role = $request->string('role')->toString();

        if ($user->id === $request->user()->id && $role !== 'admin') {
            return $this->failure('Anda tidak dapat menurunkan role sendiri.', 422);
        }

        $previous = $user->role;
        $user->update(['role' => $role]);

        $audit->log($request->user()->id, 'update_role', 'user', $user->id, [
            'previous_role' => $previous,
            'role' => $role,
        ]);

        return $this->success(new UserResource($user->fresh()));
    }
}
