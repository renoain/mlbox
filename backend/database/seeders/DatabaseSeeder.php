<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Genre;
use App\Models\Movie;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Genre bawaan untuk demo.
     *
     * @var array<int, string>
     */
    private const GENRES = ['Action', 'Drama', 'Comedy', 'Horror', 'Romance'];

    /**
     * Film contoh. Poster dan backdrop sengaja dikosongkan karena admin
     * mengunggah gambar sungguhan lewat halaman admin.
     *
     * @var array<int, array<string, mixed>>
     */
    private const MOVIES = [
        [
            'title' => 'The Silent Harbour',
            'overview' => 'Seorang pilot tua menemukan dermaga yang tidak ada di peta mana pun.',
            'release_date' => '1994-03-18',
            'runtime' => 127,
            'language' => 'en',
            'country' => 'United States',
            'cast' => 'Richard Hale, Anna Keene, Michael Doyle',
            'crew' => 'Sandra Poole',
            'genres' => ['Drama', 'Mystery'],
            'featured' => true,
        ],
        [
            'title' => 'Nightfall District',
            'overview' => 'Detektif menyelidiki hilangnya tiga orang dalam satu malam yang sama.',
            'release_date' => '1991-11-08',
            'runtime' => 114,
            'language' => 'en',
            'country' => 'United Kingdom',
            'cast' => 'Clara Whitmore, Peter Nolan',
            'crew' => 'David Reeve',
            'genres' => ['Drama'],
        ],
        [
            'title' => 'Paper Lanterns',
            'overview' => 'Seorang anak perempuan menjaga lentera ayahnya di hari pasar terakhir.',
            'release_date' => '2003-08-22',
            'runtime' => 98,
            'language' => 'ja',
            'country' => 'Japan',
            'cast' => 'Yuki Tanaka, Hiroshi Abe',
            'crew' => 'Mika Sato',
            'genres' => ['Drama', 'Romance'],
            'featured' => true,
        ],
        [
            'title' => 'Crimson Circuit',
            'overview' => 'Tim competitive harus keluar dari sorak suara sendiri.',
            'release_date' => '2019-05-30',
            'runtime' => 142,
            'language' => 'en',
            'country' => 'United States',
            'cast' => 'Victor Lund, Simone Graves, Andre Boone',
            'crew' => 'Carter Boyd',
            'genres' => ['Action'],
        ],
        [
            'title' => 'The Long Weekend',
            'overview' => 'Lima hari bersama mengubah empat pertemanan selamanya.',
            'release_date' => '2016-06-17',
            'runtime' => 105,
            'language' => 'en',
            'country' => 'United States',
            'cast' => 'Elena Rossi, Mark Fielding, Jasmine Cole',
            'crew' => 'Rita Nwosu',
            'genres' => ['Comedy', 'Drama'],
        ],
        [
            'title' => 'Below the Lighthouse',
            'overview' => 'Kisah seorang penjaga mercusuar yang mendengar suara dari dasar laut.',
            'release_date' => '1998-10-09',
            'runtime' => 118,
            'language' => 'en',
            'country' => 'Ireland',
            'cast' => 'Sean Doherty, Nora Fitzgerald',
            'crew' => 'Padraig Lynch',
            'genres' => ['Horror', 'Drama'],
        ],
        [
            'title' => 'Marigold Street',
            'overview' => 'Seorang penjaga bunga mencoba membuka toko jamtutur seperti ayahnya dulu.',
            'release_date' => '2021-02-19',
            'runtime' => 96,
            'language' => 'id',
            'country' => 'Indonesia',
            'cast' => 'Dewi Anggraini, Bagus Prasetyo',
            'crew' => 'Rani Kusuma',
            'genres' => ['Drama', 'Romance'],
            'featured' => true,
        ],
        [
            'title' => 'Static Bloom',
            'overview' => 'Musisi punk keluar dari studio dan menemukan suara yang lebih besar.',
            'release_date' => '2022-09-02',
            'runtime' => 88,
            'language' => 'en',
            'country' => 'United States',
            'cast' => 'Kira Olson',
            'crew' => 'Nolan Fry',
            'genres' => ['Drama'],
        ],
        [
            'title' => 'The Glass Orchard',
            'overview' => 'Anak-anak di sebuah desa memutuskan bahwa saat berikutnya harus tetap musiman.',
            'release_date' => '1987-07-04',
            'runtime' => 132,
            'language' => 'fr',
            'country' => 'France',
            'cast' => 'Luc Moreau, Camille Bernard',
            'crew' => 'Henri Valois',
            'genres' => ['Drama', 'Romance'],
        ],
        [
            'title' => 'Runaway Comet',
            'overview' => 'Sekelompok anak muda mengejar komet yang seharusnya sudah lama hilang.',
            'release_date' => '2023-12-15',
            'runtime' => 121,
            'language' => 'en',
            'country' => 'United States',
            'cast' => 'Tessa Vaughn, Ian Mercado, Priya Nair',
            'crew' => 'Jordan Blake',
            'genres' => ['Action', 'Comedy'],
        ],
    ];

    public function run(): void
    {
        $this->seedUsers();
        $genres = $this->seedGenres();
        $this->seedMovies($genres);
    }

    private function seedUsers(): void
    {
        $password = env('DEMO_USER_PASSWORD', 'password');

        User::firstOrCreate(
            ['email' => env('DEMO_ADMIN_EMAIL', 'admin@mailboxh.test')],
            ['name' => 'Admin', 'password' => $password, 'role' => 'admin'],
        );

        User::firstOrCreate(
            ['email' => env('DEMO_USER_EMAIL', 'demo@mailboxh.test')],
            ['name' => 'Demo User', 'password' => $password, 'role' => 'user'],
        );
    }

    /**
     * @return Collection<int, Genre>
     */
    private function seedGenres(): Collection
    {
        foreach (array_merge(self::GENRES, $this->extraGenres()) as $name) {
            Genre::firstOrCreate(['name' => $name], ['slug' => Str::slug($name)]);
        }

        return Genre::query()->get();
    }

    /**
     * @return array<int, string>
     */
    private function extraGenres(): array
    {
        $extra = [];

        foreach (self::MOVIES as $movie) {
            foreach ($movie['genres'] as $genre) {
                if (! in_array($genre, self::GENRES, true) && ! in_array($genre, $extra, true)) {
                    $extra[] = $genre;
                }
            }
        }

        return $extra;
    }

    /**
     * @param  Collection<int, Genre>  $genres
     */
    private function seedMovies(Collection $genres): void
    {
        $byName = $genres->keyBy('name');

        foreach (self::MOVIES as $data) {
            $movie = Movie::firstOrCreate(
                ['title' => $data['title']],
                [
                    'overview' => $data['overview'],
                    'release_date' => $data['release_date'],
                    'runtime' => $data['runtime'],
                    'language' => $data['language'],
                    'country' => $data['country'],
                    'cast' => $data['cast'],
                    'crew' => $data['crew'],
                    'is_featured' => $data['featured'] ?? false,
                    'poster_path' => null,
                    'backdrop_path' => null,
                ],
            );

            $ids = [];

            foreach ($data['genres'] as $name) {
                $genre = $byName->get($name) ?? Genre::firstOrCreate(
                    ['name' => $name],
                    ['slug' => Str::slug($name)],
                );
                $ids[] = $genre->id;
            }

            $movie->genres()->syncWithoutDetaching($ids);
        }
    }
}