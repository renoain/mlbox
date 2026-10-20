<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;

// Tanda suka polymorphic untuk film, review, dan list.
class Like extends Model
{
    use HasFactory;

    /**
     * @var array model yang boleh menerima tanda suka
     */
    public const TYPES = [Movie::class, Review::class, MovieList::class];

    protected $table = 'likes';

    protected $fillable = ['user_id', 'likeable_id', 'likeable_type'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function likeable(): MorphTo
    {
        return $this->morphTo();
    }
}