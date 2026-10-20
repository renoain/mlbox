<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AdminAuditLogResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'admin' => [
                'id' => $this->admin_id,
                'name' => $this->whenLoaded('admin', fn () => $this->admin->name),
            ],
            'action' => $this->action,
            'entity' => $this->entity,
            'entity_id' => $this->entity_id,
            'detail' => $this->detail,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
