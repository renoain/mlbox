<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Genre;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test pengelolaan genre oleh admin.
class AdminGenreTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());
    }

    public function test_tambah(): void
    {
        $this->admin();

        $response = $this->postJson('/api/admin/genres', ['name' => 'Sci-Fi']);

        $response->assertStatus(201)->assertJsonPath('data.slug', 'sci-fi');
    }

    public function test_edit(): void
    {
        $this->admin();
        $genre = Genre::factory()->create();

        $response = $this->putJson('/api/admin/genres/'.$genre->id, ['name' => 'Aksi']);

        $response->assertStatus(200);
    }

    public function test_hapus(): void
    {
        $this->admin();
        $genre = Genre::factory()->create();

        $response = $this->deleteJson('/api/admin/genres/'.$genre->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('genres', ['id' => $genre->id]);
    }
}
