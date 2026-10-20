<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Genre;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Genre bawaan untuk demo.
     *
     * @var array<int, string>
     */
    private const GENRES = ['Action', 'Drama', 'Comedy', 'Horror', 'Romance'];

    public function run(): void
    {
        $this->seedUsers();
        $this->seedGenres();
        $this->call(MovieSeeder::class);
    }

    private function seedUsers(): void
    {
        // `env()` mengembalikan string kosong kalau kuncinya ada di .env tapi
        // nilainya kosong, bukan nilai default. Pakai `?:` supaya kredensial
        // demo tetap punya nilai yang masuk akal.
        $password = env('DEMO_USER_PASSWORD') ?: 'password';
        $adminEmail = env('DEMO_ADMIN_EMAIL') ?: 'admin@mailboxh.test';
        $userEmail = env('DEMO_USER_EMAIL') ?: 'demo@mailboxh.test';

        // `updateOrCreate` supaya menjalankan seeder berulang kali selalu
        // menghasilkan akun demo dengan kredensial yang sama.
        User::updateOrCreate(
            ['email' => $adminEmail],
            ['name' => 'Admin', 'password' => $password, 'role' => 'admin'],
        );

        User::updateOrCreate(
            ['email' => $userEmail],
            ['name' => 'Demo User', 'password' => $password, 'role' => 'user'],
        );
    }

    private function seedGenres(): void
    {
        foreach (self::GENRES as $name) {
            Genre::firstOrCreate(['name' => $name], ['slug' => Str::slug($name)]);
        }
    }
}
