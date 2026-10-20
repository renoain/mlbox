<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\DiaryEntry;
use App\Models\DiaryTag;
use App\Models\Tag;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory penghubung tag ke entri diary.
class DiaryTagFactory extends Factory
{
    protected $model = DiaryTag::class;

    public function definition(): array
    {
        return [
            'diary_entry_id' => DiaryEntry::factory(),
            'tag_id' => Tag::factory(),
        ];
    }
}
