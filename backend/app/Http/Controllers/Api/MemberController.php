<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MemberController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = trim($request->string('q')->toString());
        $meId = $request->user()->id;

        $users = DB::table('users')
            ->where('users.id', '!=', $meId)
            ->where('users.name', 'like', '%'.$query.'%')
            ->orderBy('users.name')
            ->limit(20)
            ->get(['users.id', 'users.name']);

        $data = $users->map(function ($user) use ($meId) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'is_following' => DB::table('follows')
                    ->where('follower_id', $meId)
                    ->where('following_id', $user->id)
                    ->exists(),
                'follower_count' => DB::table('follows')->where('following_id', $user->id)->count(),
            ];
        })->all();

        return $this->success($data);
    }
}
