<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Resources\AdminAuditLogResource;
use App\Http\Resources\MovieResource;
use App\Http\Traits\ApiResponse;
use App\Models\AdminAuditLog;
use App\Models\Genre;
use App\Models\Movie;
use App\Models\MovieList;
use App\Models\Review;
use App\Models\Tag;
use App\Models\User;
use App\Models\Watched;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        return $this->success([
            'stats' => [
                'active_movies' => Movie::count(),
                'deleted_movies' => Movie::onlyTrashed()->count(),
                'total_genres' => Genre::count(),
                'total_users' => User::count(),
                'total_admins' => User::where('role', 'admin')->count(),
                'total_reviews' => Review::count(),
                'total_lists' => MovieList::count(),
                'total_tags' => Tag::count(),
            ],
            'latest_movies' => Movie::query()
                ->orderByDesc('created_at')
                ->limit(5)
                ->get()
                ->map(fn (Movie $movie) => [
                    'id' => $movie->id,
                    'title' => $movie->title,
                    'is_featured' => (bool) $movie->is_featured,
                    'created_at' => $movie->created_at?->toIso8601String(),
                ])
                ->all(),
            'recent_admin_activity' => AdminAuditLogResource::collection(
                AdminAuditLog::with('admin')->latest()->limit(10)->get()
            )->resolve($request),
            'top_watched' => DB::table('movies')
                ->leftJoin('watched', 'watched.movie_id', '=', 'movies.id')
                ->whereNull('movies.deleted_at')
                ->groupBy('movies.id', 'movies.title')
                ->orderByDesc(DB::raw('count(watched.id)'))
                ->limit(10)
                ->get([
                    'movies.id',
                    'movies.title',
                    DB::raw('count(watched.id) as watched_count'),
                ])
                ->map(fn ($row) => [
                    'id' => $row->id,
                    'title' => $row->title,
                    'watched_count' => (int) $row->watched_count,
                ])
                ->all(),
        ]);
    }
}
