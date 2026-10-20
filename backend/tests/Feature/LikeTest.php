<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Like;
use App\Models\Movie;
use App\Models\MovieList;
use App\Models\Notification;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint like polymorphic pada film, review, dan list.
class LikeTest extends TestCase
{
    use RefreshDatabase;

    public function test_like_film(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/likes', [
            'likeable_id' => $movie->id,
            'likeable_type' => Movie::class,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.liked', true)
            ->assertJsonPath('data.likes_count', 1);
    }

    public function test_unlike_film(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Like::factory()->create([
            'user_id' => $user->id,
            'likeable_id' => $movie->id,
            'likeable_type' => Movie::class,
        ]);

        $response = $this->deleteJson('/api/likes', [
            'likeable_id' => $movie->id,
            'likeable_type' => Movie::class,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.liked', false)
            ->assertJsonPath('data.likes_count', 0);
        $this->assertDatabaseCount('likes', 0);
    }

    public function test_like_review_membuat_notifikasi(): void
    {
        $liker = User::factory()->create();
        Sanctum::actingAs($liker);
        $review = Review::factory()->create();

        $response = $this->postJson('/api/likes', [
            'likeable_id' => $review->id,
            'likeable_type' => Review::class,
        ]);

        $response->assertStatus(201)->assertJsonPath('data.liked', true);
        $this->assertDatabaseHas('notifications', [
            'user_id' => $review->user_id,
            'actor_id' => $liker->id,
            'type' => Notification::TYPE_LIKE_REVIEW,
            'reference_id' => $review->id,
        ]);
    }

    public function test_like_list_membuat_notifikasi(): void
    {
        $liker = User::factory()->create();
        Sanctum::actingAs($liker);
        $list = MovieList::factory()->create(['is_public' => true]);

        $response = $this->postJson('/api/likes', [
            'likeable_id' => $list->id,
            'likeable_type' => MovieList::class,
        ]);

        $response->assertStatus(201)->assertJsonPath('data.liked', true);
        $this->assertDatabaseHas('notifications', [
            'user_id' => $list->user_id,
            'actor_id' => $liker->id,
            'type' => Notification::TYPE_LIKE_LIST,
            'reference_id' => $list->id,
        ]);
    }

    public function test_unlike_review(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $review = Review::factory()->create();
        Like::factory()->forReview($review->id)->create(['user_id' => $user->id]);

        $response = $this->deleteJson('/api/likes', [
            'likeable_id' => $review->id,
            'likeable_type' => Review::class,
        ]);

        $response->assertStatus(200)->assertJsonPath('data.liked', false);
        $this->assertDatabaseCount('likes', 0);
    }

    public function test_like_tanpa_login_ditolak(): void
    {
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/likes', [
            'likeable_id' => $movie->id,
            'likeable_type' => Movie::class,
        ]);

        $response->assertStatus(401);
    }

    public function test_like_tipe_tidak_valid_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/likes', [
            'likeable_id' => 1,
            'likeable_type' => 'App\Models\User',
        ]);

        $response->assertStatus(422);
    }

    public function test_like_objek_tidak_ada_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/likes', [
            'likeable_id' => 9999,
            'likeable_type' => Review::class,
        ]);

        $response->assertStatus(404);
    }

    public function test_unlike_yang_belum_disukai_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $movie = Movie::factory()->create();

        $response = $this->deleteJson('/api/likes', [
            'likeable_id' => $movie->id,
            'likeable_type' => Movie::class,
        ]);

        $response->assertStatus(404);
    }

    public function test_daftar_like_user(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $movie = Movie::factory()->create();
        Like::factory()->create([
            'user_id' => $user->id,
            'likeable_id' => $movie->id,
            'likeable_type' => Movie::class,
        ]);

        $response = $this->getJson('/api/likes');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_review_sertakan_likes_count_dan_is_liked(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $review = Review::factory()->create(['user_id' => $user->id]);
        Like::factory()->forReview($review->id)->create(['user_id' => $user->id]);

        $response = $this->getJson('/api/reviews');

        $response->assertStatus(200)
            ->assertJsonPath('data.0.likes_count', 1)
            ->assertJsonPath('data.0.is_liked', true);
    }

    public function test_list_sertakan_likes_count_dan_is_liked(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $list = MovieList::factory()->create(['user_id' => $user->id, 'is_public' => true]);
        Like::factory()->forList($list->id)->create(['user_id' => $user->id]);

        $response = $this->getJson('/api/lists/'.$list->id);

        $response->assertStatus(200)
            ->assertJsonPath('data.likes_count', 1)
            ->assertJsonPath('data.is_liked', true);
    }
}
