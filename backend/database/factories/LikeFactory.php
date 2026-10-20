<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Like;
use App\Models\Movie;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory tanda suka polymorphic, default ke film.
class LikeFactory extends Factory
{
    protected $model = Like::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'likeable_id' => Movie::factory(),
            'likeable_type' => Movie::class,
        ];
    }

    public function forReview(int $reviewId): static
    {
        return $this->state([
            'likeable_id' => $reviewId,
            'likeable_type' => 'App\Models\Review',
        ]);
    }

    public function forList(int $listId): static
    {
        return $this->state([
            'likeable_id' => $listId,
            'likeable_type' => 'App\Models\MovieList',
        ]);
    }
}
