<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint profil dan statistik user.
class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_profile(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/profile');

        $response->assertStatus(200)->assertJsonPath('data.email', $user->email);
    }

    public function test_stats(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->getJson('/api/profile/stats');

        $response->assertStatus(200);
        $response->assertJsonStructure(['success', 'data' => [
            'total_watched', 'total_watchlist', 'total_reviews',
            'total_likes', 'total_lists', 'total_followers', 'total_following',
        ]]);
    }
}
