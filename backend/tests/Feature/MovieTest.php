<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Movie;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

// Test katalog film publik tanpa login.
class MovieTest extends TestCase
{
    use RefreshDatabase;

    public function test_list_publik(): void
    {
        Movie::factory()->count(3)->create();

        $response = $this->getJson('/api/movies');

        $response->assertStatus(200)->assertJsonPath('success', true);
        $response->assertJsonPath('meta.total', 3);
    }

    public function test_detail_publik(): void
    {
        $movie = Movie::factory()->create();

        $response = $this->getJson('/api/movies/'.$movie->id);

        $response->assertStatus(200)->assertJsonPath('data.title', $movie->title);
    }

    public function test_detail_tidak_ada(): void
    {
        $response = $this->getJson('/api/movies/9999');

        $response->assertStatus(404)->assertJsonPath('success', false);
    }
}
