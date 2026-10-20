<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\DiaryEntry;
use App\Models\Tag;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

// Test endpoint tag pribadi dan penempelannya ke diary.
class TagTest extends TestCase
{
    use RefreshDatabase;

    public function test_buat_tag(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $response = $this->postJson('/api/tags', ['name' => 'rewatch']);

        $response->assertStatus(201)->assertJsonPath('success', true);
    }

    public function test_attach_ke_diary(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $entry = DiaryEntry::factory()->create(['user_id' => $user->id]);
        $tag = Tag::factory()->create(['user_id' => $user->id]);

        $response = $this->postJson('/api/diary/'.$entry->id.'/tags', ['tag_id' => $tag->id]);

        $response->assertStatus(201);
    }

    public function test_detach_dari_diary(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $entry = DiaryEntry::factory()->create(['user_id' => $user->id]);
        $tag = Tag::factory()->create(['user_id' => $user->id]);
        $entry->tags()->attach($tag->id);

        $response = $this->deleteJson('/api/diary/'.$entry->id.'/tags/'.$tag->id);

        $response->assertStatus(200);
    }

    public function test_hapus(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);
        $tag = Tag::factory()->create(['user_id' => $user->id]);

        $response = $this->deleteJson('/api/tags/'.$tag->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('tags', ['id' => $tag->id]);
    }
}
