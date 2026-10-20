<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Requests\UpdateFavoritesRequest;
use App\Http\Resources\FavoriteResource;
use App\Http\Traits\ApiResponse;
use App\Models\Favorite;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FavoriteController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->favorites()->with('movie.genres')->orderBy('position')->get();

        return $this->success(FavoriteResource::collection($items)->resolve($request));
    }

    public function update(UpdateFavoritesRequest $request): JsonResponse
    {
        $data = $request->validated();

        DB::transaction(function () use ($request, $data): void {
            Favorite::where('user_id', $request->user()->id)->delete();

            foreach ($data['items'] as $item) {
                Favorite::create([
                    'user_id' => $request->user()->id,
                    'movie_id' => $item['movie_id'],
                    'position' => $item['position'],
                ]);
            }
        });

        return $this->success(
            FavoriteResource::collection(
                $request->user()->favorites()->with('movie.genres')->orderBy('position')->get()
            )->resolve($request),
        );
    }
}
