<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Resources\GenreResource;
use App\Http\Traits\ApiResponse;
use App\Models\Genre;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GenreController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $genres = Genre::withCount('movies')->orderBy('name')->get();

        return $this->success(GenreResource::collection($genres)->resolve($request));
    }
}
