<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Movie;
use App\Models\User;
use App\Models\Watched;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory riwayat tontonan dengan tanggal tidak di masa depan.
class WatchedFactory extends Factory
{
    protected $model = Watched::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'movie_id' => Movie::factory(),
            'watched_at' => fake()->dateTimeBetween('-1 year', 'now')->format('Y-m-d'),
        ];
    }
}
