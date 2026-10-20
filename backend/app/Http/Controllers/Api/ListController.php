<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreListItemRequest;
use App\Http\Requests\StoreListRequest;
use App\Http\Requests\UpdateListRequest;
use App\Http\Resources\ListItemResource;
use App\Http\Resources\ListResource;
use App\Http\Traits\ApiResponse;
use App\Models\ListItem;
use App\Models\MovieList;
use App\Services\ActivityLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ListController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $userId = $request->integer('user_id') ?: $request->user()->id;
        $scope = $request->string('scope')->toString();

        $query = MovieList::query()
            ->with(['user', 'likes' => fn ($q) => $q->where('user_id', $request->user()?->id)])
            ->withCount(['items', 'likes']);

        if ($scope === 'public') {
            $query->where('is_public', true);
        } else {
            $query->where('user_id', $userId);
        }

        $lists = $query->orderByDesc('created_at')->get();

        return $this->success(ListResource::collection($lists)->resolve($request));
    }

    public function store(StoreListRequest $request, ActivityLogger $logger): JsonResponse
    {
        $list = MovieList::create([
            'user_id' => $request->user()->id,
            'title' => $request->string('title')->toString(),
            'description' => $request->input('description'),
            'is_public' => $request->boolean('is_public'),
        ]);

        $logger->log($request->user()->id, ActivityLogger::TYPE_LIST_CREATED, $list->id, [
            'title' => $list->title,
            'is_public' => (bool) $list->is_public,
        ]);

        return $this->success(new ListResource($list->loadCount('items')), null, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $list = MovieList::with([
            'user',
            'items.movie.genres',
            'likes' => fn ($q) => $q->where('user_id', $request->user()->id),
        ])->withCount(['items', 'likes'])->find($id);

        if ($list === null) {
            return $this->failure('List tidak ditemukan.', 404);
        }

        if (! $list->is_public && $list->user_id !== $request->user()->id) {
            return $this->failure('List ini privat.', 403);
        }

        return $this->success([
            'id' => $list->id,
            'user_id' => $list->user_id,
            'owner_name' => $list->user->name,
            'title' => $list->title,
            'description' => $list->description,
            'is_public' => (bool) $list->is_public,
            'item_count' => $list->items_count,
            'likes_count' => $list->likes_count,
            'is_liked' => $list->likes->contains('user_id', $request->user()->id),
            'can_edit' => $list->user_id === $request->user()->id,
            'items' => ListItemResource::collection($list->items)->resolve($request),
        ]);
    }

    public function update(UpdateListRequest $request, int $id): JsonResponse
    {
        $list = $request->user()->lists()->find($id);

        if ($list === null) {
            return $this->failure('List tidak ditemukan.', 404);
        }

        $list->update($request->validated());

        return $this->success(new ListResource($list->fresh('user')->loadCount('items')));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $deleted = $request->user()->lists()->where('id', $id)->delete();

        if ($deleted === 0) {
            return $this->failure('List tidak ditemukan.', 404);
        }

        return $this->success(null);
    }

    public function storeItem(StoreListItemRequest $request, int $id): JsonResponse
    {
        $list = $request->user()->lists()->find($id);

        if ($list === null) {
            return $this->failure('List tidak ditemukan.', 404);
        }

        $movieId = $request->integer('movie_id');

        if ($list->items()->where('movie_id', $movieId)->exists()) {
            return $this->failure('Film sudah ada di list ini.', 409);
        }

        $item = ListItem::create([
            'list_id' => $list->id,
            'movie_id' => $movieId,
            'note' => $request->input('note'),
            'order_index' => ((int) $list->items()->max('order_index')) + 1,
        ]);

        return $this->success(new ListItemResource($item->load('movie.genres')), null, 201);
    }

    public function updateItems(Request $request, int $id): JsonResponse
    {
        $list = $request->user()->lists()->find($id);

        if ($list === null) {
            return $this->failure('List tidak ditemukan.', 404);
        }

        $data = $request->validate([
            'order' => ['required', 'array'],
            'order.*' => ['integer'],
        ]);

        DB::transaction(function () use ($list, $data): void {
            foreach ($data['order'] as $index => $movieId) {
                $list->items()->where('movie_id', $movieId)->update(['order_index' => $index]);
            }
        });

        return $this->success(
            ListItemResource::collection($list->fresh('items.movie.genres')->items)->resolve($request)
        );
    }

    public function destroyItem(Request $request, int $id, int $movieId): JsonResponse
    {
        $list = $request->user()->lists()->find($id);

        if ($list === null) {
            return $this->failure('List tidak ditemukan.', 404);
        }

        $deleted = $list->items()->where('movie_id', $movieId)->delete();

        if ($deleted === 0) {
            return $this->failure('Film tidak ada di list ini.', 404);
        }

        return $this->success(null);
    }
}
