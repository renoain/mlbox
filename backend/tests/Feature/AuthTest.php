<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint autentikasi register, login, logout, dan me.
class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_sukses(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Budi',
            'email' => 'budi@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)->assertJsonPath('success', true);
        $this->assertDatabaseHas('users', ['email' => 'budi@example.com']);
    }

    public function test_register_email_duplikat(): void
    {
        User::factory()->create(['email' => 'budi@example.com']);

        $response = $this->postJson('/api/register', [
            'name' => 'Budi',
            'email' => 'budi@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(422);
    }

    public function test_login_sukses(): void
    {
        User::factory()->create(['email' => 'budi@example.com']);

        $response = $this->postJson('/api/login', [
            'email' => 'budi@example.com',
            'password' => 'password',
        ]);

        $response->assertStatus(200)->assertJsonPath('success', true);
        $response->assertJsonStructure(['success', 'data' => ['user', 'token']]);
    }

    public function test_login_password_salah(): void
    {
        User::factory()->create(['email' => 'budi@example.com']);

        $response = $this->postJson('/api/login', [
            'email' => 'budi@example.com',
            'password' => 'salah-password',
        ]);

        $response->assertStatus(401)->assertJsonPath('success', false);
    }

    public function test_login_email_tidak_ada(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'tidakada@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(401)->assertJsonPath('success', false);
    }

    public function test_logout(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/logout');

        $response->assertStatus(200)->assertJsonPath('success', true);
    }

    public function test_me_dengan_token(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/me');

        $response->assertStatus(200)->assertJsonPath('data.email', $user->email);
    }

    public function test_me_tanpa_token(): void
    {
        $response = $this->getJson('/api/me');

        $response->assertStatus(401);
    }

    public function test_rate_limit_login(): void
    {
        for ($i = 0; $i < 10; $i++) {
            $response = $this->postJson('/api/login', [
                'email' => 'spam@example.com',
                'password' => 'password123',
            ]);
        }

        $response->assertStatus(429);
    }
}
