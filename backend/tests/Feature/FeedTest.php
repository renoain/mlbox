<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Activity;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint activity feed.
class FeedTest extends TestCase
{
    use RefreshDatabase;

    public function test_feed_kosong(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->getJson('/api/feed');

        $response->assertStatus(200)->assertJsonCount(0, 'data');
    }

    public function test_feed_setelah_aktivitas(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        Activity::factory()->create(['user_id' => $user->id, 'type' => 'liked']);

        $response = $this->getJson('/api/feed');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }
}
