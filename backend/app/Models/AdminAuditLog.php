<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdminAuditLog extends Model
{
    use HasFactory;

    protected $fillable = ['admin_id', 'action', 'entity', 'entity_id', 'detail'];

    public function admin()
    {
        return $this->belongsTo(User::class, 'admin_id');
    }
}
