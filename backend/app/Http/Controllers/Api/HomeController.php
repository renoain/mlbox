<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\MovieResource;
use App\Http\Traits\ApiResponse;
use App\Models\Movie;
use App\Services\HomeService;
use App\Services\MovieStatsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly HomeService $home,
        private readonly MovieStatsService $stats,
    ) {
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
        // Agregat dihitung sekali untuk seluruh section, lalu dipakai ulang
        // oleh tiap film. Film yang belum punya review/watchlist/watch tetap
        // dapat kunci di map dengan nilai nol.
        $statsMap = $this->stats->statsMap($movies->modelKeys());

        return $movies
            ->map(fn (Movie $movie) => MovieResource::withStats($movie, $statsMap))
            ->map->resolve($request)
            ->values()
            ->all();
    }
}
