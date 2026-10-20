<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Movie;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory film katalog dengan data contoh yang valid.
class MovieFactory extends Factory
{
    protected $model = Movie::class;

    public function definition(): array
    {
        return [
            'title' => fake()->unique()->sentence(3),
            'original_title' => fake()->optional()->sentence(3),
            'overview' => fake()->optional()->paragraph(),
            'release_date' => fake()->optional()->date(),
            'poster_path' => null,
            'backdrop_path' => null,
            'runtime' => fake()->optional()->numberBetween(80, 180),
            'language' => fake()->optional()->randomElement(['en', 'id', 'ja']),
            'country' => fake()->optional()->country(),
            'cast' => fake()->optional()->name().', '.fake()->name(),
            'crew' => fake()->optional()->name(),
            'is_featured' => false,
        ];
    }
}
