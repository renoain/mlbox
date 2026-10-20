<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\AdminAuditLog;

/**
 * Satu-satunya kelas yang menulis ke tabel admin_audit_logs.
 *
 * Riwayat audit tidak punya endpoint hapus dan tidak punya soft delete.
 */
class AdminAuditService
{
    /**
     * @param  array<string, mixed>|string|null  $detail  ringkasan perubahan
     */
    public function log(
        int $adminId,
        string $action,
        string $entity,
        ?int $entityId = null,
        array|string|null $detail = null,
    ): void {
        AdminAuditLog::create([
            'admin_id' => $adminId,
            'action' => $action,
            'entity' => $entity,
            'entity_id' => $entityId,
            'detail' => is_array($detail) ? json_encode($detail, JSON_UNESCAPED_UNICODE) : $detail,
        ]);
    }
}