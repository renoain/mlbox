<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Movie;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

// Representasi like polymorphic pada film, review, dan list.
class LikeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'likeable_id' => $this->likeable_id,
            'likeable_type' => $this->likeable_type,
            'liked_at' => $this->created_at?->toIso8601String(),
            // Data film-nya ikut dikirim kalau yang di-like memang film,
            // supaya klien tidak perlu request satu per film.
            'movie' => $this->whenLoaded(
                'likeable',
                fn () => $this->likeable instanceof Movie
                    ? new MovieResource($this->likeable)
                    : null,
            ),
        ];
    }
}
