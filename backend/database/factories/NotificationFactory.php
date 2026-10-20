<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory notifikasi sosial yang belum dibaca.
class NotificationFactory extends Factory
{
    protected $model = Notification::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'actor_id' => User::factory(),
            'type' => Notification::TYPE_LIKE_REVIEW,
            'reference_id' => 1,
            'is_read' => false,
        ];
    }
}
