<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Resources\TagResource;
use App\Http\Traits\ApiResponse;
use App\Models\Tag;
use App\Services\AdminAuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminTagController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Tag::query()->with('user')->withCount('diaryEntries');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q')->toString().'%');
        }

        if ($request->filled('user_id')) {
            $query->where('user_id', $request->integer('user_id'));
        }

        $tags = $query->orderByDesc('diary_entries_count')->paginate(20)->withQueryString();

        return $this->success(
            TagResource::collection($tags->getCollection())->resolve($request),
            ['page' => $tags->currentPage(), 'total' => $tags->total()],
        );
    }

    public function destroy(Request $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $tag = Tag::with('user')->find($id);

        if ($tag === null) {
            return $this->failure('Tag tidak ditemukan.', 404);
        }

        $tag->delete();

        $audit->log($request->user()->id, 'delete', 'tag', $id, [
            'name' => $tag->name,
            'owner_name' => $tag->user->name,
        ]);

        return $this->success(null);
    }
}
