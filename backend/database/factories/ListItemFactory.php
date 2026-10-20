<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\ListItem;
use App\Models\Movie;
use App\Models\MovieList;
use Illuminate\Database\Eloquent\Factories\Factory;

// Factory anggota list beserta urutannya.
class ListItemFactory extends Factory
{
    protected $model = ListItem::class;

    public function definition(): array
    {
        return [
            'list_id' => MovieList::factory(),
            'movie_id' => Movie::factory(),
            'note' => fake()->optional()->sentence(),
            'order_index' => 0,
        ];
    }
}
