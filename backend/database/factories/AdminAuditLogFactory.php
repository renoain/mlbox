<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\AdminAuditLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory log audit tindakan admin.
class AdminAuditLogFactory extends Factory
{
    protected $model = AdminAuditLog::class;

    public function definition(): array
    {
        return [
            'admin_id' => User::factory(),
            'action' => fake()->randomElement(['create', 'update', 'deactivate', 'restore', 'feature']),
            'entity' => fake()->randomElement(['movie', 'genre', 'user', 'review', 'list', 'tag']),
            'entity_id' => fake()->optional()->randomNumber(),
            'detail' => fake()->optional()->sentence(),
        ];
    }
}
