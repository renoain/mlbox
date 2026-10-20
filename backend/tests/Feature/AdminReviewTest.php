<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test moderasi review oleh admin.
class AdminReviewTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());
    }

    public function test_list_semua_review(): void
    {
        $this->admin();
        Review::factory()->count(2)->create();

        $response = $this->getJson('/api/admin/reviews');

        $response->assertStatus(200)->assertJsonPath('meta.total', 2);
    }

    public function test_hapus_review(): void
    {
        $this->admin();
        $review = Review::factory()->create();

        $response = $this->deleteJson('/api/admin/reviews/'.$review->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('reviews', ['id' => $review->id]);
    }
}
