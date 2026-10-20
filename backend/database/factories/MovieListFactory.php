<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\MovieList;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory list kurasi, tabel lists lewat model MovieList.
class MovieListFactory extends Factory
{
    protected $model = MovieList::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'title' => fake()->sentence(3),
            'description' => fake()->optional()->paragraph(),
            'is_public' => false,
        ];
    }
}
