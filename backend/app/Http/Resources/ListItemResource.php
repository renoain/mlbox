<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ListItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'movie_id' => $this->movie_id,
            'movie' => new MovieResource($this->whenLoaded('movie')),
            'note' => $this->note,
            'order_index' => $this->order_index,
        ];
    }
}
