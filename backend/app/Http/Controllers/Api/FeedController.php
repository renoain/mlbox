<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\ActivityResource;
use App\Http\Traits\ApiResponse;
use App\Models\Activity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FeedController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $query = Activity::query()->with('user')->where(function ($q) use ($userId): void {
            $q->where('user_id', $userId)
                ->orWhereIn('user_id', function ($sub) use ($userId): void {
                    $sub->select('following_id')->from('follows')->where('follower_id', $userId);
                });
        });

        if ($request->filled('type')) {
            $query->where('type', $request->string('type')->toString());
        }

        $limit = min($request->integer('limit', 5), 50);
        $activities = $query->latest()->limit($limit)->get();

        return $this->success(ActivityResource::collection($activities)->resolve($request));
    }
}
