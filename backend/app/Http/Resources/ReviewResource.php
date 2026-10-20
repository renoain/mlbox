<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

// Representasi review termasuk jumlah like, status like user, dan komentar.
class ReviewResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'movie_id' => $this->movie_id,
            'movie' => new MovieResource($this->whenLoaded('movie')),
            'user_id' => $this->user_id,
            'user_name' => $this->whenLoaded('user', fn () => $this->user->name),
            'rating' => $this->rating,
            'content' => $this->content,
            'likes_count' => $this->likes_count ?? $this->likes()->count(),
            'is_liked' => $this->likedBy($request),
            'comments' => CommentResource::collection($this->whenLoaded('comments')),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }

    private function likedBy(Request $request): bool
    {
        $userId = $request->user()?->id;

        if ($userId === null) {
            return false;
        }

        if ($this->relationLoaded('likes')) {
            return $this->likes->contains('user_id', $userId);
        }

        return $this->likes()->where('user_id', $userId)->exists();
    }
}
