<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint empat film favorit.
class FavoriteTest extends TestCase
{
    use RefreshDatabase;

    public function test_set_empat_favorit(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movies = Movie::factory()->count(4)->create();

        $response = $this->putJson('/api/favorites', [
            'items' => $movies->map(fn ($movie, $index) => [
                'position' => $index + 1,
                'movie_id' => $movie->id,
            ])->all(),
        ]);

        $response->assertStatus(200)->assertJsonCount(4, 'data');
    }

    public function test_lebih_dari_empat(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movies = Movie::factory()->count(5)->create();

        $response = $this->putJson('/api/favorites', [
            'items' => $movies->map(fn ($movie, $index) => [
                'position' => $index + 1,
                'movie_id' => $movie->id,
            ])->all(),
        ]);

        $response->assertStatus(422);
    }

    public function test_list(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->getJson('/api/favorites');

        $response->assertStatus(200)->assertJsonPath('success', true);
    }
}
