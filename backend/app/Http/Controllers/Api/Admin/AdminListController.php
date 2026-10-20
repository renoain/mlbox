<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Resources\ListResource;
use App\Http\Traits\ApiResponse;
use App\Models\MovieList;
use App\Services\AdminAuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminListController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = MovieList::query()->with('user')->withCount('items');

        if ($request->filled('q')) {
            $query->where('title', 'like', '%'.$request->string('q')->toString().'%');
        }

        match ($request->string('scope')->toString()) {
            'public' => $query->where('is_public', true),
            'private' => $query->where('is_public', false),
            default => $query,
        };

        $lists = $query->orderByDesc('created_at')->paginate(20)->withQueryString();

        return $this->success(
            ListResource::collection($lists->getCollection())->resolve($request),
            ['page' => $lists->currentPage(), 'total' => $lists->total()],
        );
    }

    public function destroy(Request $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $list = MovieList::with('user')->find($id);

        if ($list === null) {
            return $this->failure('List tidak ditemukan.', 404);
        }

        $ownerName = $list->user->name;
        $list->delete();

        $audit->log($request->user()->id, 'delete', 'list', $id, [
            'title' => $list->title,
            'owner_name' => $ownerName,
        ]);

        return $this->success(null);
    }
}
