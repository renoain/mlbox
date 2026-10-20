<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Admin;

use App\Http\Resources\AdminAuditLogResource;
use App\Http\Traits\ApiResponse;
use App\Models\AdminAuditLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminAuditLogController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = AdminAuditLog::query()->with('admin');

        if ($request->filled('admin_id')) {
            $query->where('admin_id', $request->integer('admin_id'));
        }

        if ($request->filled('entity')) {
            $query->where('entity', $request->string('entity')->toString());
        }

        $logs = $query->latest()->paginate(20)->withQueryString();

        return $this->success(
            AdminAuditLogResource::collection($logs->getCollection())->resolve($request),
            ['page' => $logs->currentPage(), 'total' => $logs->total()],
        );
    }
}
