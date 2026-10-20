<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Activity;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory aktivitas feed dengan type yang valid.
class ActivityFactory extends Factory
{
    protected $model = Activity::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'type' => fake()->randomElement(['watched', 'rated', 'reviewed', 'liked', 'list_created', 'followed']),
            'reference_id' => fake()->optional()->randomNumber(),
            'metadata' => null,
        ];
    }
}
