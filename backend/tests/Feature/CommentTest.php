<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Comment;
use App\Models\Notification;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint komentar pada review.
class CommentTest extends TestCase
{
    use RefreshDatabase;

    public function test_buat_komentar(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $review = Review::factory()->create();

        $response = $this->postJson('/api/reviews/'.$review->id.'/comments', [
            'content' => 'Setuju dengan review ini.',
        ]);

        $response->assertStatus(201)->assertJsonPath('data.content', 'Setuju dengan review ini.');
        $this->assertDatabaseHas('comments', [
            'review_id' => $review->id,
            'user_id' => $user->id,
        ]);
    }

    public function test_buat_komentar_membuat_notifikasi(): void
    {
        $commenter = User::factory()->create();
        Sanctum::actingAs($commenter);
        $review = Review::factory()->create();

        $this->postJson('/api/reviews/'.$review->id.'/comments', [
            'content' => 'Komentar untuk notifikasi.',
        ]);

        $comment = Comment::firstOrFail();
        $this->assertDatabaseHas('notifications', [
            'user_id' => $review->user_id,
            'actor_id' => $commenter->id,
            'type' => Notification::TYPE_COMMENT_REVIEW,
            'reference_id' => $comment->id,
        ]);
    }

    public function test_daftar_komentar(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $review = Review::factory()->create();
        Comment::factory()->create(['review_id' => $review->id]);

        $response = $this->getJson('/api/reviews/'.$review->id.'/comments');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_hapus_komentar_sendiri(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $comment = Comment::factory()->create(['user_id' => $user->id]);

        $response = $this->deleteJson('/api/comments/'.$comment->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('comments', ['id' => $comment->id]);
    }

    public function test_hapus_komentar_orang_lain_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $comment = Comment::factory()->create();

        $response = $this->deleteJson('/api/comments/'.$comment->id);

        $response->assertStatus(403);
        $this->assertDatabaseHas('comments', ['id' => $comment->id]);
    }

    public function test_komentar_kosong_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $review = Review::factory()->create();

        $response = $this->postJson('/api/reviews/'.$review->id.'/comments', [
            'content' => '',
        ]);

        $response->assertStatus(422);
    }

    public function test_komentar_lebih_dari_1000_karakter_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $review = Review::factory()->create();

        $response = $this->postJson('/api/reviews/'.$review->id.'/comments', [
            'content' => str_repeat('a', 1001),
        ]);

        $response->assertStatus(422);
    }

    public function test_review_tidak_ada_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/reviews/9999/comments', [
            'content' => 'Komentar.',
        ]);

        $response->assertStatus(404);
    }

    public function test_komentar_tanpa_login_ditolak(): void
    {
        $review = Review::factory()->create();

        $response = $this->postJson('/api/reviews/'.$review->id.'/comments', [
            'content' => 'Komentar.',
        ]);

        $response->assertStatus(401);
    }
}
