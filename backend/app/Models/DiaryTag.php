<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DiaryTag extends Model
{
    use HasFactory;

    protected $fillable = ['diary_entry_id', 'tag_id'];
}
