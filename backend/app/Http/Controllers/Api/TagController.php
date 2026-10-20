<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreTagRequest;
use App\Http\Resources\TagResource;
use App\Http\Traits\ApiResponse;
use App\Models\Tag;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TagController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $tags = $request->user()->tags()->withCount('diaryEntries')->orderBy('name')->get();

        return $this->success(TagResource::collection($tags)->resolve($request));
    }

    public function store(StoreTagRequest $request): JsonResponse
    {
        $name = $request->string('name')->toString();

        if ($request->user()->tags()->whereRaw('lower(name) = ?', [mb_strtolower($name)])->exists()) {
            return $this->failure('Tag dengan nama tersebut sudah ada.', 409);
        }

        $tag = Tag::create([
            'user_id' => $request->user()->id,
            'name' => $name,
        ]);

        return $this->success(new TagResource($tag->loadCount('diaryEntries')), null, 201);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $deleted = $request->user()->tags()->where('id', $id)->delete();

        if ($deleted === 0) {
            return $this->failure('Tag tidak ditemukan.', 404);
        }

        return $this->success(null);
    }

    public function attachToDiary(Request $request, int $id): JsonResponse
    {
        $data = $request->validate(['tag_id' => ['required', 'integer', 'exists:tags,id']]);

        $entry = $request->user()->diaryEntries()->find($id);

        if ($entry === null) {
            return $this->failure('Entri diary tidak ditemukan.', 404);
        }

        $tag = $request->user()->tags()->find($data['tag_id']);

        if ($tag === null) {
            return $this->failure('Tag tidak ditemukan.', 404);
        }

        if ($entry->tags()->where('tags.id', $tag->id)->exists()) {
            return $this->failure('Tag sudah ditempel pada entri ini.', 409);
        }

        $entry->tags()->attach($tag->id);

        return $this->success(new TagResource($tag), null, 201);
    }

    public function detachFromDiary(Request $request, int $id, int $tagId): JsonResponse
    {
        $entry = $request->user()->diaryEntries()->find($id);

        if ($entry === null) {
            return $this->failure('Entri diary tidak ditemukan.', 404);
        }

        if ($entry->tags()->where('tags.id', $tagId)->doesntExist()) {
            return $this->failure('Tag tidak ditempel pada entri ini.', 404);
        }

        $entry->tags()->detach($tagId);

        return $this->success(null);
    }
}
