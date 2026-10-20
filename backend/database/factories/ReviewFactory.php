<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Movie;
use App\Models\Review;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory rating 1 sampai 5 beserta isi review.
class ReviewFactory extends Factory
{
    protected $model = Review::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'movie_id' => Movie::factory(),
            'rating' => fake()->numberBetween(1, 5),
            'content' => fake()->optional()->paragraph(),
        ];
    }
}
