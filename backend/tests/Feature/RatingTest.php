<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint rating bintang tanpa entri diary.
class RatingTest extends TestCase
{
    use RefreshDatabase;

    public function test_rate_membuat_review_tanpa_diary(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/movies/'.$movie->id.'/rate', ['rating' => 4]);

        $response->assertStatus(201)->assertJsonPath('data.rating', 4);
        $this->assertDatabaseHas('reviews', [
            'user_id' => $user->id,
            'movie_id' => $movie->id,
            'rating' => 4,
            'content' => null,
        ]);
        $this->assertDatabaseCount('diary_entries', 0);
    }

    public function test_rate_kedua_kali_memperbarui_nilai(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        $review = Review::factory()->create([
            'user_id' => $user->id,
            'movie_id' => $movie->id,
            'rating' => 2,
            'content' => null,
        ]);

        $response = $this->postJson('/api/movies/'.$movie->id.'/rate', ['rating' => 5]);

        $response->assertStatus(200)->assertJsonPath('data.review_id', $review->id);
        $this->assertDatabaseCount('reviews', 1);
        $this->assertDatabaseHas('reviews', ['id' => $review->id, 'rating' => 5]);
    }

    public function test_unrate_menghapus_review_tanpa_teks(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        $review = Review::factory()->create([
            'user_id' => $user->id,
            'movie_id' => $movie->id,
            'rating' => 3,
            'content' => null,
        ]);

        $response = $this->deleteJson('/api/movies/'.$movie->id.'/rate');

        $response->assertStatus(200)->assertJsonPath('data.rating', null);
        $this->assertDatabaseMissing('reviews', ['id' => $review->id]);
    }

    public function test_unrate_mempertahankan_teks_review(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        $review = Review::factory()->create([
            'user_id' => $user->id,
            'movie_id' => $movie->id,
            'rating' => 4,
            'content' => 'Teks review tetap ada.',
        ]);

        $response = $this->deleteJson('/api/movies/'.$movie->id.'/rate');

        $response->assertStatus(200);
        $this->assertDatabaseHas('reviews', [
            'id' => $review->id,
            'rating' => null,
            'content' => 'Teks review tetap ada.',
        ]);
    }

    public function test_rate_nilai_di_luar_satu_sampai_lima_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/movies/'.$movie->id.'/rate', ['rating' => 6]);

        $response->assertStatus(422);
    }

    public function test_rate_tanpa_nilai_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/movies/'.$movie->id.'/rate', []);

        $response->assertStatus(422);
    }

    public function test_unrate_film_belum_diberi_rating_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->deleteJson('/api/movies/'.$movie->id.'/rate');

        $response->assertStatus(404);
    }

    public function test_rate_film_tidak_ada_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/movies/9999/rate', ['rating' => 3]);

        $response->assertStatus(404);
    }

    public function test_rate_tanpa_login_ditolak(): void
    {
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/movies/'.$movie->id.'/rate', ['rating' => 3]);

        $response->assertStatus(401);
    }
}
