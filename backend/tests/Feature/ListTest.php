<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\MovieList;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint list kurasi milik user yang login.
class ListTest extends TestCase
{
    use RefreshDatabase;

    public function test_buat_list(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/lists', [
            'title' => 'Klasik 90an',
            'is_public' => true,
        ]);

        $response->assertStatus(201)->assertJsonPath('success', true);
    }

    public function test_tambah_film(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $list = MovieList::factory()->create(['user_id' => $user->id]);
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/lists/'.$list->id.'/items', ['movie_id' => $movie->id]);

        $response->assertStatus(201);
    }

    public function test_hapus_film(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $list = MovieList::factory()->create(['user_id' => $user->id]);
        $movie = Movie::factory()->create();
        $list->items()->create(['movie_id' => $movie->id, 'order_index' => 0]);

        $response = $this->deleteJson('/api/lists/'.$list->id.'/items/'.$movie->id);

        $response->assertStatus(200);
    }

    public function test_hapus_list(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $list = MovieList::factory()->create(['user_id' => $user->id]);

        $response = $this->deleteJson('/api/lists/'.$list->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('lists', ['id' => $list->id]);
    }

    public function test_list_publik_user_lain(): void
    {
        $other = User::factory()->create();
        Sanctum::actingAs(User::factory()->create());
        $list = MovieList::factory()->create(['user_id' => $other->id, 'is_public' => true]);

        $response = $this->getJson('/api/lists/'.$list->id);

        $response->assertStatus(200)->assertJsonPath('data.can_edit', false);
    }
}
