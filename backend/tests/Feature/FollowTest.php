<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint follow antar user.
class FollowTest extends TestCase
{
    use RefreshDatabase;

    public function test_follow(): void
    {
        Sanctum::actingAs(User::factory()->create());
        $target = User::factory()->create();

        $response = $this->postJson('/api/follow/'.$target->id);

        $response->assertStatus(200)->assertJsonPath('data.is_following', true);
    }

    public function test_unfollow(): void
    {
        $me = User::factory()->create();
        Sanctum::actingAs($me);
        $target = User::factory()->create();
        $me->following()->attach($target->id);

        $response = $this->deleteJson('/api/follow/'.$target->id);

        $response->assertStatus(200)->assertJsonPath('data.is_following', false);
    }

    public function test_followers(): void
    {
        $me = User::factory()->create();
        Sanctum::actingAs($me);
        $fan = User::factory()->create();
        $fan->following()->attach($me->id);

        $response = $this->getJson('/api/followers');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_following(): void
    {
        $me = User::factory()->create();
        Sanctum::actingAs($me);
        $target = User::factory()->create();
        $me->following()->attach($target->id);

        $response = $this->getJson('/api/following');

        $response->assertStatus(200)->assertJsonCount(1, 'data');
    }
}
