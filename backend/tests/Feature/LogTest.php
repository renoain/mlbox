<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\User;
use App\Models\Watchlist;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test form log tontonan beserta rating dan tag.
class LogTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_log_with_tags(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/log', [
            'movie_id' => $movie->id,
            'watched_at' => now()->toDateString(),
            'note' => 'Nonton bareng teman.',
            'rating' => 4,
            'content' => 'Bagus.',
            'tags' => ['rewatch', 'nonton bareng'],
        ]);

        $response->assertStatus(201)->assertJsonPath('success', true);
        $this->assertDatabaseHas('watched', ['user_id' => $user->id, 'movie_id' => $movie->id]);
        $this->assertDatabaseHas('diary_entries', ['user_id' => $user->id, 'movie_id' => $movie->id]);
        $this->assertDatabaseHas('reviews', ['user_id' => $user->id, 'movie_id' => $movie->id]);
        $this->assertDatabaseHas('tags', ['user_id' => $user->id, 'name' => 'rewatch']);
    }

    public function test_user_can_create_log_without_tags(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/log', ['movie_id' => $movie->id]);

        $response->assertStatus(201)->assertJsonPath('success', true);
    }

    public function test_create_log_requires_token(): void
    {
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/log', ['movie_id' => $movie->id]);

        $response->assertStatus(401);
    }

    public function test_create_log_with_invalid_movie_id(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/log', ['movie_id' => 9999]);

        $response->assertStatus(422);
    }

    public function test_log_menghapus_film_dari_watchlist(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Watchlist::factory()->create(['user_id' => $user->id, 'movie_id' => $movie->id]);

        $this->postJson('/api/log', ['movie_id' => $movie->id])->assertStatus(201);

        $this->assertDatabaseMissing('watchlist', [
            'user_id' => $user->id,
            'movie_id' => $movie->id,
        ]);
    }

    public function test_log_dua_kali_tanggal_sama_ditolak(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();

        $this->postJson('/api/log', [
            'movie_id' => $movie->id,
            'watched_at' => '2026-01-01',
        ])->assertStatus(201);

        $this->postJson('/api/log', [
            'movie_id' => $movie->id,
            'watched_at' => '2026-01-01',
        ])->assertStatus(409);

        $this->assertDatabaseCount('diary_entries', 1);
    }
}
