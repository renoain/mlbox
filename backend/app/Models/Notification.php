<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

// Notifikasi sosial yang diterima user: like, komentar, dan follow.
class Notification extends Model
{
    use HasFactory;

    public const TYPE_LIKE_REVIEW = 'like_review';
    public const TYPE_COMMENT_REVIEW = 'comment_review';
    public const TYPE_FOLLOW = 'follow';
    public const TYPE_LIKE_LIST = 'like_list';

    public const UPDATED_AT = null;

    protected $fillable = ['user_id', 'actor_id', 'type', 'reference_id', 'is_read'];

    protected function casts(): array
    {
        return ['is_read' => 'boolean'];
    }

    public function recipient()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function actor()
    {
        return $this->belongsTo(User::class, 'actor_id');
    }
}