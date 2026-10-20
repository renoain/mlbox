<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\DiaryEntry;
use App\Models\Movie;
use App\Models\User;
use App\Models\Watchlist;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint diary milik user yang login.
class DiaryTest extends TestCase
{
    use RefreshDatabase;

    public function test_buat_entri(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/diary', [
            'movie_id' => $movie->id,
            'watched_date' => now()->toDateString(),
            'note' => 'Nonton bareng teman.',
        ]);

        $response->assertStatus(201)->assertJsonPath('success', true);
    }

    public function test_list(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        DiaryEntry::factory()->create(['user_id' => $user->id]);

        $response = $this->getJson('/api/diary');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_edit(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $entry = DiaryEntry::factory()->create(['user_id' => $user->id]);

        $response = $this->putJson('/api/diary/'.$entry->id, ['note' => 'Revisi catatan.']);

        $response->assertStatus(200);
    }

    public function test_hapus(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $entry = DiaryEntry::factory()->create(['user_id' => $user->id]);

        $response = $this->deleteJson('/api/diary/'.$entry->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('diary_entries', ['id' => $entry->id]);
    }

    public function test_tanggal_format_salah(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/diary', [
            'movie_id' => $movie->id,
            'watched_date' => 'bukan-tanggal',
        ]);

        $response->assertStatus(422);
    }

    public function test_entri_kedua_tanggal_berbeda_diizinkan(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        DiaryEntry::factory()->create([
            'user_id' => $user->id,
            'movie_id' => $movie->id,
            'watched_date' => '2026-01-01',
        ]);

        $response = $this->postJson('/api/diary', [
            'movie_id' => $movie->id,
            'watched_date' => '2026-01-02',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseCount('diary_entries', 2);
    }

    public function test_entri_tanggal_sama_ditolak(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        DiaryEntry::factory()->create([
            'user_id' => $user->id,
            'movie_id' => $movie->id,
            'watched_date' => '2026-01-01',
        ]);

        $response = $this->postJson('/api/diary', [
            'movie_id' => $movie->id,
            'watched_date' => '2026-01-01',
        ]);

        $response->assertStatus(409);
        $this->assertDatabaseCount('diary_entries', 1);
    }

    public function test_log_menghapus_film_dari_watchlist(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Watchlist::factory()->create(['user_id' => $user->id, 'movie_id' => $movie->id]);

        $this->postJson('/api/diary', [
            'movie_id' => $movie->id,
            'watched_date' => now()->toDateString(),
        ])->assertStatus(201);

        $this->assertDatabaseMissing('watchlist', [
            'user_id' => $user->id,
            'movie_id' => $movie->id,
        ]);
    }
}
