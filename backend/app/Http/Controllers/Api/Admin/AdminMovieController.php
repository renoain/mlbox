<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreMovieRequest;
use App\Http\Requests\Admin\UpdateMovieRequest;
use App\Http\Resources\MovieResource;
use App\Http\Traits\ApiResponse;
use App\Models\Movie;
use App\Services\AdminAuditService;
use App\Services\MovieStatsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminMovieController extends Controller
{
    use ApiResponse;

    public const FEATURED_LIMIT = 5;

    public function __construct(private readonly MovieStatsService $stats)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $query = Movie::query()->with('genres')->withCount(['watchlists', 'watcheds', 'reviews', 'likes']);

        if ($request->string('status')->toString() === 'deleted') {
            $query->onlyTrashed();
        }

        if ($request->filled('q')) {
            $query->where('title', 'like', '%'.$request->string('q')->toString().'%');
        }

        $movies = $query->orderByDesc('created_at')->paginate(20)->withQueryString();

        $collection = $movies->getCollection();
        $statsMap = $this->stats->statsMap($collection->modelKeys());

        $resources = $collection
            ->map(fn (Movie $movie) => MovieResource::withStats($movie, $statsMap))
            ->values();

        return $this->success(
            MovieResource::collection($resources)->resolve($request),
            [
                'page' => $movies->currentPage(),
                'per_page' => $movies->perPage(),
                'total' => $movies->total(),
            ],
        );
    }

    public function store(StoreMovieRequest $request, AdminAuditService $audit): JsonResponse
    {
        $data = $this->validated($request, true);

        if ($request->boolean('is_featured') && $this->featuredCount() >= self::FEATURED_LIMIT) {
            return $this->failure('Maksimal lima film dapat ditandai featured.', 409);
        }

        $movie = DB::transaction(function () use ($request, $data): Movie {
            $movie = Movie::create($data['attributes']);
            $movie->genres()->sync($data['genres'] ?? []);

            return $movie;
        });

        $audit->log($request->user()->id, 'create', 'movie', $movie->id, ['title' => $movie->title]);

        return $this->success(new MovieResource($movie->load('genres')), null, 201);
    }

    public function update(UpdateMovieRequest $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $movie = Movie::withTrashed()->find($id);

        if ($movie === null) {
            return $this->failure('Film tidak ditemukan.', 404);
        }

        $data = $this->validated($request, false);

        if ($request->boolean('is_featured') && ! $movie->is_featured && $this->featuredCount() >= self::FEATURED_LIMIT) {
            return $this->failure('Maksimal lima film dapat ditandai featured.', 409);
        }

        DB::transaction(function () use ($movie, $data): void {
            $movie->update($data['attributes']);
            $movie->genres()->sync($data['genres'] ?? $movie->genres->pluck('id')->all());
        });

        $audit->log($request->user()->id, 'update', 'movie', $movie->id, [
            'title' => $movie->title,
            'previous_title' => $data['previous_title'] ?? null,
        ]);

        return $this->success(new MovieResource($movie->fresh('genres')));
    }

    public function destroy(Request $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $movie = Movie::find($id);

        if ($movie === null) {
            return $this->failure('Film tidak ditemukan.', 404);
        }

        $movie->delete();

        $audit->log($request->user()->id, 'deactivate', 'movie', $movie->id, [
            'title' => $movie->title,
        ]);

        return $this->success([
            'id' => $movie->id,
            'deleted_at' => $movie->deleted_at?->toIso8601String(),
        ]);
    }

    public function restore(Request $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $movie = Movie::onlyTrashed()->find($id);

        if ($movie === null) {
            return $this->failure('Film tidak ditemukan.', 404);
        }

        $movie->restore();

        $audit->log($request->user()->id, 'restore', 'movie', $movie->id, [
            'title' => $movie->title,
        ]);

        return $this->success(new MovieResource($movie->load('genres')));
    }

    public function toggleFeature(Request $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $movie = Movie::find($id);

        if ($movie === null) {
            return $this->failure('Film tidak ditemukan.', 404);
        }

        $target = (bool) $request->boolean('is_featured');

        if ($target && $this->featuredCount() >= self::FEATURED_LIMIT) {
            return $this->failure('Maksimal lima film dapat ditandai featured.', 409);
        }

        $movie->update(['is_featured' => $target]);

        $audit->log($request->user()->id, $target ? 'feature' : 'unfeature', 'movie', $movie->id, [
            'title' => $movie->title,
        ]);

        return $this->success(new MovieResource($movie->load('genres')));
    }

    private function featuredCount(): int
    {
        return Movie::where('is_featured', true)->count();
    }

    /**
     * Menyimpan file gambar dan membentuk atribut film.
     *
     * @return array{attributes: array<string, mixed>, genres: array<int, int>|null, previous_title: string|null}
     */
    private function validated(StoreMovieRequest|UpdateMovieRequest $request, bool $creating): array
    {
        $safe = $request->safe();
        $attributes = $safe->except(['poster', 'backdrop', 'genres', 'poster_clear', 'backdrop_clear']);

        if ($request->hasFile('poster')) {
            $path = $request->file('poster')->store('posters', 'public');
            $attributes['poster_path'] = $path;
        } elseif ($request->boolean('poster_clear')) {
            $attributes['poster_path'] = null;
        }

        if ($request->hasFile('backdrop')) {
            $path = $request->file('backdrop')->store('backdrops', 'public');
            $attributes['backdrop_path'] = $path;
        } elseif ($request->boolean('backdrop_clear')) {
            $attributes['backdrop_path'] = null;
        }

        return [
            'attributes' => $attributes,
            'genres' => $request->input('genres'),
            'previous_title' => $creating ? null : ($safe['title'] ?? null),
        ];
    }
}