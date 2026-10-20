<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Movie extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'title',
        'original_title',
        'overview',
        'release_date',
        'poster_path',
        'backdrop_path',
        'runtime',
        'language',
        'country',
        'cast',
        'crew',
        'is_featured',
    ];

    protected function casts(): array
    {
        return [
            'release_date' => 'date',
            'is_featured' => 'boolean',
        ];
    }

    public function genres()
    {
        return $this->belongsToMany(Genre::class, 'movie_genres');
    }

    public function watchlists()
    {
        return $this->hasMany(Watchlist::class);
    }

    public function watcheds()
    {
        return $this->hasMany(Watched::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function diaryEntries()
    {
        return $this->hasMany(DiaryEntry::class);
    }

    public function listItems()
    {
        return $this->hasMany(ListItem::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }

    public function likes()
    {
        return $this->morphMany(Like::class, 'likeable');
    }
}
