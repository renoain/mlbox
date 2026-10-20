<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test dashboard admin dan penolakan role user biasa.
class AdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_biasa_ditolak(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->getJson('/api/admin/dashboard');

        $response->assertStatus(403)->assertJsonPath('success', false);
    }

    public function test_admin_sukses(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());

        $response = $this->getJson('/api/admin/dashboard');

        $response->assertStatus(200);
        $response->assertJsonStructure(['success', 'data' => [
            'stats', 'latest_movies', 'recent_admin_activity', 'top_watched',
        ]]);
    }
}
