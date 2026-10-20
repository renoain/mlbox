<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ListItem extends Model
{
    use HasFactory;

    protected $fillable = ['list_id', 'movie_id', 'note', 'order_index'];

    public function list()
    {
        return $this->belongsTo(MovieList::class, 'list_id');
    }

    public function movie()
    {
        return $this->belongsTo(Movie::class);
    }
}
