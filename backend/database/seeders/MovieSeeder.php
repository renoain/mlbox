?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Genre;
use App\Models\Movie;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class MovieSeeder extends Seeder
{
    public function run(): void
    {
        $path = database_path('data/movies.json');

        if (! File::exists($path)) {
            return;
        }

        $movies = json_decode(File::get($path), true, 512, JSON_THROW_ON_ERROR);
        $genres = Genre::query()->get()->keyBy('name');

        foreach ($movies as $data) {
            $movie = Movie::firstOrCreate(
                ['title' => $data['title']],
                [
                    'original_title' => $data['original_title'] ?? null,
                    'overview' => $data['overview'] ?? null,
                    'release_date' => $data['release_date'] ?? null,
                    'runtime' => $data['runtime'] ?? null,
                    'language' => $data['language'] ?? null,
                    'country' => $data['country'] ?? null,
                    'cast' => $data['cast'] ?? null,
                    'crew' => $data['crew'] ?? null,
                    'is_featured' => $data['is_featured'] ?? false,
                    'poster_path' => isset($data['poster_filename']) ? 'posters/'.$data['poster_filename'] : null,
                    'backdrop_path' => null,
                ],
            );

            // Update poster_path if missing
            if ($movie->poster_path === null && isset($data['poster_filename'])) {
                $movie->poster_path = 'posters/'.$data['poster_filename'];
                $movie->save();
            }

            $ids = [];
            foreach ($data['genres'] ?? [] as $name) {
                $genre = $genres->get($name) ?? Genre::firstOrCreate(
                    ['name' => $name],
                    ['slug' => Str::slug($name)],
                );
                $genres->put($genre->name, $genre);
                $ids[] = $genre->id;
            }

            if ($ids !== []) {
                $movie->genres()->syncWithoutDetaching($ids);
            }
        }
    }
}
