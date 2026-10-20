<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DiaryEntry extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'movie_id', 'watched_date', 'note'];

    protected function casts(): array
    {
        return ['watched_date' => 'date'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function movie()
    {
        return $this->belongsTo(Movie::class);
    }

    public function tags()
    {
        return $this->belongsToMany(Tag::class, 'diary_tags');
    }
}
