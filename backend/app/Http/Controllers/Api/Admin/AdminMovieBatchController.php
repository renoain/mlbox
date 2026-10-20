<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Requests\Admin\StoreMovieBatchRequest;
use App\Http\Traits\ApiResponse;
use App\Services\MovieBatchImportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

// Import film massal dari zip oleh admin.
class AdminMovieBatchController extends Controller
{
    use ApiResponse;

    public function import(StoreMovieBatchRequest $request, MovieBatchImportService $service): JsonResponse
    {
        $report = $service->import($request->file('file'), $request->user()->id);

        return $this->success($report, null, 201);
    }

    public function resolve(Request $request, MovieBatchImportService $service): JsonResponse
    {
        $request->validate(['mapping' => ['required', 'array']]);

        $service->resolve((array) $request->input('mapping'));

        return $this->success(null);
    }
}
