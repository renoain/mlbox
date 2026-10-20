<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\MovieResource;
use App\Http\Traits\ApiResponse;
use App\Models\Movie;
use App\Services\HomeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly HomeService $home)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $data = $this->home->getHomeData();

        $payload = [];

        foreach ($data as $section => $movies) {
            $payload[$section] = $this->mapSection($section, $movies, $request);
        }

        return $this->success($payload);
    }

    /**
     * @param  \Illuminate\Support\Collection<int, Movie>  $movies
     * @return array<int, array<string, mixed>>
     */
    private function mapSection(string $section, $movies, Request $request): array
    {
        if ($section === 'most_watched') {
            return $movies->map(fn (Movie $movie) => MovieResource::make($movie)->additional([
                'watched_count' => $movie->watcheds_count,
            ])->resolve($request))->all();
        }

        if ($section === 'most_watchlisted') {
            return $movies->map(fn (Movie $movie) => MovieResource::make($movie)->additional([
                'watchlist_count' => $movie->watchlists_count,
            ])->resolve($request))->all();
        }

        return MovieResource::collection($movies)->resolve($request);
    }
}
