<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Services\MovieStatsService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MovieResource extends JsonResource
{
    /**
     * Apakah payload menyertakan angka agregat (rating, review, watchlist).
     *
     * Sengaja memakai properti publik, bukan argumen constructor kedua.
     * Laravel memetakan koleksi dengan `new MovieResource($model, $key)`,
     * jadi argumen kedua constructor berisi *kunci* koleksi (0, 1, 2, ...),
     * bukan flag boolean. Dengan flag di argumen constructor, film
     * pertama selalu kehilangan agregat sedangkan film sisanya
     * mendapatkannya.
     */
    public bool $withStats = false;

    /**
     * Agregat yang sudah dihitung sekali untuk seluruh film.
     *
     * Kalau null, angka agregat dihitung satu per film (cukup untuk
     * detail satu film, terlalu mahal untuk daftar film).
     *
     * @var array<int, array<string, mixed>>|null
     */
    public ?array $statsMap = null;

    /**
     * Argumen kedua diabaikan.
     *
     * Laravel memanggil `new MovieResource($model, $key)` saat memetakan
     * koleksi, jadi parameter ini wajib ada agar pemanggilan itu tidak
     * menimpa apa pun.
     */
    public function __construct($resource, mixed $key = null)
    {
        parent::__construct($resource);
    }

    /**
     * Resource film yang menyertakan angka agregat.
     *
     * @param  array<int, array<string, mixed>>|null  $statsMap
     */
    public static function withStats($resource, ?array $statsMap = null): self
    {
        $instance = new static($resource);
        $instance->withStats = true;
        $instance->statsMap = $statsMap;

        return $instance;
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
            $data += $this->statsForMovie();
        }

        return $data;
    }

    /**
     * Angka agregat untuk film ini.
     *
     * @return array<string, mixed>
     */
    private function statsForMovie(): array
    {
        $id = (int) $this->id;

        if ($this->statsMap !== null) {
            return $this->statsMap[$id] ?? MovieStatsService::emptyStats();
        }

        return app(MovieStatsService::class)->statsFor($id);
    }

    /**
     * URL absolut untuk berkas gambar.
     *
     * Disajikan lewat route `GET /api/media/{path}` (bukan `/storage/...`)
     * supaya responsnya membawa header CORS. Tanpa header itu, Flutter Web
     * tidak bisa memuat poster karena browser memblokir permintaan gambar
     * lintas origin.
     */
    private function imageUrl(?string $path): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }

        $relative = ltrim(str_replace('\\', '/', $path), '/');

        return rtrim((string) config('app.url'), '/').'/api/media/'.$relative;
    }
}
