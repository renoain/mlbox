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

// Test endpoint notifikasi sosial milik user yang login.
class NotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_notifikasi_like_review_muncul_di_list(): void
    {
        $liker = User::factory()->create();
        $owner = User::factory()->create();
        Sanctum::actingAs($owner);
        $review = Review::factory()->create(['user_id' => $owner->id]);

        Sanctum::actingAs($liker);
        $this->postJson('/api/likes', [
            'likeable_id' => $review->id,
            'likeable_type' => Review::class,
        ]);

        Sanctum::actingAs($owner);
        $response = $this->getJson('/api/notifications');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.type', Notification::TYPE_LIKE_REVIEW)
            ->assertJsonPath('data.0.actor_id', $liker->id)
            ->assertJsonPath('data.0.is_read', false);
    }

    public function test_notifikasi_komentar_muncul_di_list(): void
    {
        $owner = User::factory()->create();
        Sanctum::actingAs($owner);
        $review = Review::factory()->create(['user_id' => $owner->id]);

        Sanctum::actingAs(User::factory()->create());
        $this->postJson('/api/reviews/'.$review->id.'/comments', [
            'content' => 'Komentar memicu notifikasi.',
        ]);

        Sanctum::actingAs($owner);
        $response = $this->getJson('/api/notifications');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.type', Notification::TYPE_COMMENT_REVIEW);
    }

    public function test_notifikasi_follow_muncul_di_list(): void
    {
        $target = User::factory()->create();
        $follower = User::factory()->create();

        Sanctum::actingAs($follower);
        $this->postJson('/api/follow/'.$target->id);

        Sanctum::actingAs($target);
        $response = $this->getJson('/api/notifications');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.type', Notification::TYPE_FOLLOW)
            ->assertJsonPath('data.0.actor_id', $follower->id);
    }

    public function test_tidak_ada_notifikasi_untuk_diri_sendiri(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $review = Review::factory()->create(['user_id' => $user->id]);

        $this->postJson('/api/likes', [
            'likeable_id' => $review->id,
            'likeable_type' => Review::class,
        ]);

        $this->assertDatabaseCount('notifications', 0);
    }

    public function test_list_notifikasi_hanya_milik_user_login(): void
    {
        $user = User::factory()->create();
        Notification::factory()->create(['user_id' => $user->id]);
        Notification::factory()->create();

        Sanctum::actingAs($user);
        $response = $this->getJson('/api/notifications');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_tandai_satu_notifikasi_dibaca(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $notification = Notification::factory()->create(['user_id' => $user->id]);

        $response = $this->putJson('/api/notifications/'.$notification->id.'/read');

        $response->assertStatus(200)->assertJsonPath('data.is_read', true);
        $this->assertDatabaseHas('notifications', ['id' => $notification->id, 'is_read' => true]);
    }

    public function test_notifikasi_orang_lain_tidak_bisa_ditandai(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $notification = Notification::factory()->create();

        $response = $this->putJson('/api/notifications/'.$notification->id.'/read');

        $response->assertStatus(404);
        $this->assertDatabaseHas('notifications', ['id' => $notification->id, 'is_read' => false]);
    }

    public function test_tandai_semua_notifikasi_dibaca(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        Notification::factory()->create(['user_id' => $user->id]);
        Notification::factory()->create(['user_id' => $user->id]);

        $response = $this->putJson('/api/notifications/read-all');

        $response->assertStatus(200)->assertJsonPath('data.updated', 2);
        $this->assertDatabaseCount('notifications', 2);
        $this->assertSame(
            0,
            Notification::where('user_id', $user->id)->where('is_read', false)->count(),
        );
    }

    public function test_notifikasi_tanpa_login_ditolak(): void
    {
        $response = $this->getJson('/api/notifications');

        $response->assertStatus(401);
    }
}
