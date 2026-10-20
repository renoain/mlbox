<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\User;
use App\Models\Watched;
use App\Models\Watchlist;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint watched milik user yang login.
class WatchedTest extends TestCase
{
    use RefreshDatabase;

    public function test_tandai_watched(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/watched', [
            'movie_id' => $movie->id,
            'watched_at' => now()->toDateString(),
        ]);

        $response->assertStatus(201)->assertJsonPath('success', true);
    }

    public function test_list(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        Watched::factory()->create(['user_id' => $user->id]);

        $response = $this->getJson('/api/watched');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_hapus(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Watched::factory()->create(['user_id' => $user->id, 'movie_id' => $movie->id]);

        $response = $this->deleteJson('/api/watched/'.$movie->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('watched', ['user_id' => $user->id, 'movie_id' => $movie->id]);
    }

    public function test_tanpa_token(): void
    {
        $response = $this->getJson('/api/watched');

        $response->assertStatus(401);
    }

    public function test_watched_tidak_membuat_entri_diary(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $this->postJson('/api/watched', [
            'movie_id' => $movie->id,
            'watched_at' => now()->toDateString(),
        ])->assertStatus(201);

        $this->assertDatabaseCount('diary_entries', 0);
    }

    public function test_watched_menghapus_film_dari_watchlist(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Watchlist::factory()->create(['user_id' => $user->id, 'movie_id' => $movie->id]);

        $this->postJson('/api/watched', [
            'movie_id' => $movie->id,
            'watched_at' => now()->toDateString(),
        ])->assertStatus(201);

        $this->assertDatabaseMissing('watchlist', [
            'user_id' => $user->id,
            'movie_id' => $movie->id,
        ]);
    }
}
