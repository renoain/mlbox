<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Services\MovieStatsService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MovieResource extends JsonResource
{
    /**
     * Menyertakan angka agregat pada payload film.
     */
    public function __construct($resource, private readonly bool $withStats = false)
    {
        parent::__construct($resource);
    }

    public static function withStats($resource): self
    {
        return new self($resource, true);
    }

    public function toArray(Request $request): array
    {
        $data = [
            'id' => $this->id,
            'title' => $this->title,
            'original_title' => $this->original_title,
            'overview' => $this->overview,
            'release_date' => $this->release_date?->toDateString(),
            'poster_url' => $this->imageUrl($this->poster_path),
            'backdrop_url' => $this->imageUrl($this->backdrop_path),
            'runtime' => $this->runtime,
            'language' => $this->language,
            'country' => $this->country,
            'cast' => $this->cast,
            'crew' => $this->crew,
            'is_featured' => (bool) $this->is_featured,
            'deleted_at' => $this->deleted_at?->toIso8601String(),
            'genres' => GenreResource::collection($this->whenLoaded('genres')),
        ];

        if ($this->withStats) {
            $stats = app(MovieStatsService::class);
            $data['average_rating'] = $stats->getAverageRating($this->id);
            $data['review_count'] = $stats->getReviewCount($this->id);
            $data['watched_count'] = $stats->getWatchedCount($this->id);
            $data['watchlist_count'] = $stats->getWatchlistCount($this->id);
        }

        return $data;
    }

    private function imageUrl(?string $path): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }

        return rtrim((string) config('app.url'), '/').'/storage/'.$path;
    }
}