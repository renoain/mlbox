<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Movie;
use App\Models\User;
use App\Models\Watchlist;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory baris watchlist milik user.
class WatchlistFactory extends Factory
{
    protected $model = Watchlist::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'movie_id' => Movie::factory(),
        ];
    }
}
