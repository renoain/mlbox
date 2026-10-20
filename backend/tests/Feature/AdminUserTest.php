<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test pengelolaan user oleh admin.
class AdminUserTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        return $admin;
    }

    public function test_list(): void
    {
        $this->admin();
        User::factory()->count(2)->create();

        $response = $this->getJson('/api/admin/users');

        $response->assertStatus(200)->assertJsonPath('meta.total', 3);
    }

    public function test_detail(): void
    {
        $this->admin();
        $user = User::factory()->create();

        $response = $this->getJson('/api/admin/users/'.$user->id);

        $response->assertStatus(200)->assertJsonPath('data.id', $user->id);
    }

    public function test_ubah_role(): void
    {
        $this->admin();
        $user = User::factory()->create();

        $response = $this->putJson('/api/admin/users/'.$user->id.'/role', ['role' => 'admin']);

        $response->assertStatus(200);
        $this->assertDatabaseHas('users', ['id' => $user->id, 'role' => 'admin']);
    }

    public function test_cegah_ubah_role_sendiri(): void
    {
        $admin = $this->admin();

        $response = $this->putJson('/api/admin/users/'.$admin->id.'/role', ['role' => 'user']);

        $response->assertStatus(422);
    }
}
