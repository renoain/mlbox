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
use ZipArchive;

// Test import film massal dari zip oleh admin.
class AdminBatchImportTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());
    }

    private function makeZip(array $files): UploadedFile
    {
        $path = tempnam(sys_get_temp_dir(), 'batch').'.zip';
        $zip = new ZipArchive();
        $zip->open($path, ZipArchive::CREATE);

        foreach ($files as $name => $content) {
            $zip->addFromString($name, $content);
        }

        $zip->close();

        return new UploadedFile($path, 'batch.zip', 'application/zip', null, true);
    }

    private function moviesJson(): string
    {
        return (string) json_encode([
            [
                'title' => 'Import Satu',
                'overview' => 'Film pertama dari batch.',
                'release_date' => '2020-01-01',
                'runtime' => 100,
                'language' => 'en',
                'genres' => ['Action'],
                'poster_filename' => 'satu.jpg',
            ],
            [
                'title' => 'Nightfall District',
                'overview' => 'Cocok lewat normalisasi judul.',
                'genres' => ['Drama'],
            ],
        ]);
    }

    public function test_import_zip_valid(): void
    {
        Storage::fake('public');
        $this->admin();

        $response = $this->post('/api/admin/movies/batch-import', [
            'file' => $this->makeZip([
                'movies.json' => $this->moviesJson(),
                'posters/satu.jpg' => 'biner-poster-satu',
                'posters/nightfalldistrict.jpg' => 'biner-poster-dua',
            ]),
        ]);

        $response->assertStatus(201)->assertJsonPath('success', true);
        $response->assertJsonPath('data.created', 2);
        $this->assertDatabaseHas('movies', ['title' => 'Import Satu']);
    }

    public function test_import_tanpa_movies_json(): void
    {
        Storage::fake('public');
        $this->admin();

        $response = $this->post('/api/admin/movies/batch-import', [
            'file' => $this->makeZip(['posters/satu.jpg' => 'biner']),
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('data.created', 0);
        $this->assertNotEmpty($response->json('data.errors'));
    }

    public function test_poster_tidak_match_masuk_unmatched(): void
    {
        Storage::fake('public');
        $this->admin();

        $response = $this->post('/api/admin/movies/batch-import', [
            'file' => $this->makeZip([
                'movies.json' => (string) json_encode([[
                    'title' => 'Tanpa Poster',
                    'poster_filename' => 'hilang.jpg',
                ]]),
            ]),
        ]);

        $response->assertStatus(201)->assertJsonPath('data.created', 1);
        $response->assertJsonCount(1, 'data.unmatched');
    }

    public function test_resolve_unmatched(): void
    {
        Storage::fake('public');
        $this->admin();
        $movie = Movie::factory()->create();
        $poster = tempnam(sys_get_temp_dir(), 'poster').'.jpg';
        file_put_contents($poster, 'biner-poster');

        $response = $this->postJson('/api/admin/movies/batch-resolve', [
            'mapping' => [$movie->id => $poster],
        ]);

        $response->assertStatus(200);
        $this->assertNotNull($movie->fresh()->poster_path);
    }
}
