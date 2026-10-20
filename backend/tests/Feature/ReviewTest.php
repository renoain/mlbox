<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint rating dan review milik user yang login.
class ReviewTest extends TestCase
{
    use RefreshDatabase;

    public function test_buat_review(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/reviews', [
            'movie_id' => $movie->id,
            'rating' => 4,
            'content' => 'Bagus.',
        ]);

        $response->assertStatus(201)->assertJsonPath('success', true);
    }

    public function test_edit(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $review = Review::factory()->create(['user_id' => $user->id]);

        $response = $this->putJson('/api/reviews/'.$review->id, [
            'rating' => 5,
            'content' => 'Sangat bagus.',
        ]);

        $response->assertStatus(200)->assertJsonPath('data.rating', 5);
    }

    public function test_hapus(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $review = Review::factory()->create(['user_id' => $user->id]);

        $response = $this->deleteJson('/api/reviews/'.$review->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('reviews', ['id' => $review->id]);
    }

    public function test_rating_di_luar_rentang(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/reviews', [
            'movie_id' => $movie->id,
            'rating' => 6,
        ]);

        $response->assertStatus(422);
    }
}
