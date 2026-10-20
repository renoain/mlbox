<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\User;
use App\Models\Watchlist;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint watchlist milik user yang login.
class WatchlistTest extends TestCase
{
    use RefreshDatabase;

    public function test_tambah(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/watchlist', ['movie_id' => $movie->id]);

        $response->assertStatus(201)->assertJsonPath('success', true);
    }

    public function test_tambah_duplikat(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Watchlist::factory()->create(['user_id' => $user->id, 'movie_id' => $movie->id]);

        $response = $this->postJson('/api/watchlist', ['movie_id' => $movie->id]);

        $response->assertStatus(409);
    }

    public function test_list(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        Watchlist::factory()->create(['user_id' => $user->id]);

        $response = $this->getJson('/api/watchlist');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_hapus(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Watchlist::factory()->create(['user_id' => $user->id, 'movie_id' => $movie->id]);

        $response = $this->deleteJson('/api/watchlist/'.$movie->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('watchlist', ['user_id' => $user->id, 'movie_id' => $movie->id]);
    }

    public function test_tanpa_token(): void
    {
        $response = $this->getJson('/api/watchlist');

        $response->assertStatus(401);
    }
}
