<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test pengelolaan film oleh admin.
class AdminMovieTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        return $admin;
    }

    public function test_tanpa_role_admin(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/admin/movies', ['title' => 'Judul Film']);

        $response->assertStatus(403);
    }

    public function test_tambah_film(): void
    {
        $this->admin();

        $response = $this->postJson('/api/admin/movies', ['title' => 'Judul Film']);

        $response->assertStatus(201)->assertJsonPath('success', true);
        $this->assertDatabaseHas('movies', ['title' => 'Judul Film']);
    }

    public function test_edit(): void
    {
        $this->admin();
        $movie = Movie::factory()->create();

        $response = $this->putJson('/api/admin/movies/'.$movie->id, ['title' => 'Judul Baru']);

        $response->assertStatus(200)->assertJsonPath('data.title', 'Judul Baru');
    }

    public function test_soft_delete(): void
    {
        $this->admin();
        $movie = Movie::factory()->create();

        $response = $this->deleteJson('/api/admin/movies/'.$movie->id);

        $response->assertStatus(200);
        $this->assertSoftDeleted('movies', ['id' => $movie->id]);
    }

    public function test_restore(): void
    {
        $this->admin();
        $movie = Movie::factory()->create();
        $movie->delete();

        $response = $this->postJson('/api/admin/movies/'.$movie->id.'/restore');

        $response->assertStatus(200);
        $this->assertDatabaseHas('movies', ['id' => $movie->id, 'deleted_at' => null]);
    }

    public function test_toggle_feature(): void
    {
        $this->admin();
        $movie = Movie::factory()->create();

        $response = $this->postJson('/api/admin/movies/'.$movie->id.'/feature', ['is_featured' => true]);

        $response->assertStatus(200);
    }

    public function test_upload_poster_valid(): void
    {
        Storage::fake('public');
        $this->admin();

        $response = $this->post('/api/admin/movies', [
            'title' => 'Film Berposter',
            'poster' => UploadedFile::fake()->create('poster.jpg', 500, 'image/jpeg'),
        ]);

        $response->assertStatus(201);
    }

    public function test_upload_bukan_gambar(): void
    {
        $this->admin();

        $response = $this->post('/api/admin/movies', [
            'title' => 'Film Dokumen',
            'poster' => UploadedFile::fake()->create('doc.pdf', 100, 'application/pdf'),
        ]);

        $response->assertStatus(422);
    }

    public function test_upload_lebih_dari_2mb(): void
    {
        $this->admin();

        $response = $this->post('/api/admin/movies', [
            'title' => 'Film Besar',
            'poster' => UploadedFile::fake()->create('besar.jpg', 3000, 'image/jpeg'),
        ]);

        $response->assertStatus(422);
    }
}
