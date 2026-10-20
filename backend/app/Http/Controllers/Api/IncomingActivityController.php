<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Traits\ApiResponse;
use App\Models\Movie;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class IncomingActivityController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $type = $request->string('type')->toString();

        $followers = collect();

        if ($type === '' || $type === 'followed') {
            $followers = DB::table('activities')
                ->join('users', 'users.id', '=', 'activities.user_id')
                ->where('activities.type', 'followed')
                ->where('activities.user_id', '!=', $userId)
                ->whereExists(function ($sub) use ($userId): void {
                    $sub->select(DB::raw(1))
                        ->from('follows')
                        ->whereColumn('follows.id', 'activities.reference_id')
                        ->where('follows.following_id', $userId);
                })
                ->orderByDesc('activities.created_at')
                ->limit(30)
                ->get(['users.id as actor_id', 'users.name as actor_name', 'activities.created_at']);
        }

        $likes = collect();

        if ($type === '' || $type === 'liked') {
            $likes = DB::table('likes')
                ->join('users', 'users.id', '=', 'likes.user_id')
                ->join('list_items', 'list_items.movie_id', '=', 'likes.likeable_id')
                ->join('lists', 'lists.id', '=', 'list_items.list_id')
                ->join('movies', 'movies.id', '=', 'likes.likeable_id')
                ->where('likes.likeable_type', Movie::class)
                ->where('lists.is_public', true)
                ->where('lists.user_id', $userId)
                ->where('likes.user_id', '!=', $userId)
                ->whereNull('movies.deleted_at')
                ->orderByDesc('likes.created_at')
                ->limit(30)
                ->get([
                    'users.id as actor_id',
                    'users.name as actor_name',
                    'likes.likeable_id as movie_id',
                    'likes.created_at',
                    'movies.title',
                    'movies.poster_path',
                ]);
        }

        $data = [
            ...$followers->map(fn ($row) => [
                'id' => null,
                'type' => 'followed',
                'actor' => ['id' => $row->actor_id, 'name' => $row->actor_name],
                'target' => ['movie_id' => null, 'title' => null, 'poster_path' => null],
                'created_at' => $row->created_at,
            ])->all(),
            ...$likes->map(fn ($row) => [
                'id' => null,
                'type' => 'liked',
                'actor' => ['id' => $row->actor_id, 'name' => $row->actor_name],
                'target' => [
                    'movie_id' => $row->movie_id,
                    'title' => $row->title,
                    'poster_path' => $row->poster_path,
                ],
                'created_at' => $row->created_at,
            ])->all(),
        ];

        usort($data, fn ($a, $b) => strcmp((string) $b['created_at'], (string) $a['created_at']));

        return $this->success(array_slice($data, 0, 30));
    }
}
