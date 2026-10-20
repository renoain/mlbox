<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\DiaryEntry;
use App\Models\Movie;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory catatan diary milik user.
class DiaryEntryFactory extends Factory
{
    protected $model = DiaryEntry::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'movie_id' => Movie::factory(),
            'watched_date' => fake()->dateTimeBetween('-1 year', 'now')->format('Y-m-d'),
            'note' => fake()->optional()->sentence(),
        ];
    }
}
