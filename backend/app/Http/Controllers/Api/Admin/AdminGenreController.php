<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Requests\Admin\StoreGenreRequest;
use App\Http\Requests\Admin\UpdateGenreRequest;
use App\Http\Resources\GenreResource;
use App\Http\Traits\ApiResponse;
use App\Models\Genre;
use App\Services\AdminAuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AdminGenreController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $genres = Genre::withCount('movies')->orderBy('name')->get();

        return $this->success(GenreResource::collection($genres)->resolve($request));
    }

    public function store(StoreGenreRequest $request, AdminAuditService $audit): JsonResponse
    {
        $name = $request->string('name')->toString();
        $slug = $request->input('slug') ?: Str::slug($name);

        if ($this->exists($name, $slug)) {
            return $this->failure('Genre dengan nama atau slug tersebut sudah ada.', 409);
        }

        $genre = Genre::create(['name' => $name, 'slug' => $slug]);

        $audit->log($request->user()->id, 'create', 'genre', $genre->id, ['name' => $genre->name]);

        return $this->success(new GenreResource($genre->loadCount('movies')), null, 201);
    }

    public function update(UpdateGenreRequest $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $genre = Genre::find($id);

        if ($genre === null) {
            return $this->failure('Genre tidak ditemukan.', 404);
        }

        $name = $request->string('name')->toString();
        $slug = $request->input('slug') ?: Str::slug($name);

        if ($this->exists($name, $slug, $genre->id)) {
            return $this->failure('Genre dengan nama atau slug tersebut sudah ada.', 409);
        }

        $genre->update(['name' => $name, 'slug' => $slug]);

        $audit->log($request->user()->id, 'update', 'genre', $genre->id, ['name' => $name]);

        return $this->success(new GenreResource($genre->fresh()->loadCount('movies')));
    }

    public function destroy(Request $request, int $id, AdminAuditService $audit): JsonResponse
    {
        $genre = Genre::find($id);

        if ($genre === null) {
            return $this->failure('Genre tidak ditemukan.', 404);
        }

        $genre->movies()->detach();
        $genre->delete();

        $audit->log($request->user()->id, 'delete', 'genre', $genre->id, [
            'name' => $genre->name,
            'mode' => 'detach',
        ]);

        return $this->success(null);
    }

    private function exists(string $name, string $slug, ?int $ignoreId = null): bool
    {
        return Genre::query()
            ->where('id', '!=', $ignoreId ?? 0)
            ->where(function ($q) use ($name, $slug): void {
                $q->whereRaw('lower(name) = ?', [mb_strtolower($name)])
                    ->orWhere('slug', $slug);
            })
            ->exists();
    }
}
