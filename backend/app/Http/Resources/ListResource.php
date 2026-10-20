<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

// Representasi list film termasuk jumlah like dan status like user.
class ListResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'owner_name' => $this->whenLoaded('user', fn () => $this->user->name),
            'title' => $this->title,
            'description' => $this->description,
            'is_public' => (bool) $this->is_public,
            'item_count' => $this->whenCounted('items'),
            'likes_count' => $this->likes_count ?? $this->likes()->count(),
            'is_liked' => $this->likedBy($request),
            'can_edit' => $request->user()?->id === $this->user_id,
            'created_at' => $this->created_at?->toIso8601String(),
            'items' => ListItemResource::collection($this->whenLoaded('items')),
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
