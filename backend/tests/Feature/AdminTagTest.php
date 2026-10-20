<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\DiaryEntry;
use App\Models\Tag;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test moderasi tag oleh admin.
class AdminTagTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): void
    {
        Sanctum::actingAs(User::factory()->admin()->create());
    }

    public function test_admin_can_list_tags(): void
    {
        $this->admin();
        Tag::factory()->create();

        $response = $this->getJson('/api/admin/tags');

        $response->assertStatus(200)->assertJsonPath('success', true);
        $response->assertJsonStructure(['success', 'data' => [['id', 'name', 'usage_count']]]);
    }

    public function test_admin_list_tags_sorted_by_usage(): void
    {
        $user = User::factory()->create();
        $this->admin();
        $often = Tag::factory()->create(['user_id' => $user->id, 'name' => 'sering']);
        $rare = Tag::factory()->create(['user_id' => $user->id, 'name' => 'jarang']);
        Tag::factory()->create(['user_id' => $user->id, 'name' => 'tak-terpakai']);

        foreach ([1, 2] as $i) {
            $entry = DiaryEntry::factory()->create(['user_id' => $user->id]);
            $entry->tags()->attach($often->id);
        }

        $entry = DiaryEntry::factory()->create(['user_id' => $user->id]);
        $entry->tags()->attach($rare->id);

        $response = $this->getJson('/api/admin/tags');

        $response->assertStatus(200);
        $names = collect($response->json('data'))->pluck('name')->all();
        $this->assertSame(['sering', 'jarang', 'tak-terpakai'], $names);
    }

    public function test_non_admin_cannot_list_tags(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->getJson('/api/admin/tags');

        $response->assertStatus(403);
    }

    public function test_admin_can_delete_tag(): void
    {
        $this->admin();
        $tag = Tag::factory()->create();

        $response = $this->deleteJson('/api/admin/tags/'.$tag->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('tags', ['id' => $tag->id]);
    }
}
