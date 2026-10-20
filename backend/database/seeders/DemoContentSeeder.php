<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Movie;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Seeder data dummy dalam jumlah banyak, supaya aplikasi terlihat hidup saat
 * didemokan.
 *
 * Jalankan:
 *   php artisan db:seed --class=DemoContentSeeder
 *
 * Seeder ini aman dijalankan berulang kali: baris yang melanggar unique
 * constraint dilewati lewat `insertOrIgnore`.
 */
class DemoContentSeeder extends Seeder
{
    /** Jumlah user palsu yang dibuat. */
    private const USER_COUNT = 100;

    /** Rentang jumlah reviewer per film. */
    private const REVIEWERS_MIN = 30;
    private const REVIEWERS_MAX = 50;

    /** Rentang jumlah liker per film. */
    private const LIKERS_MIN = 20;
    private const LIKERS_MAX = 40;

    /** Jumlah user yang punya entri diary. */
    private const DIARY_USERS = 50;

    /** Rentang jumlah film per entri diary. */
    private const DIARY_MOVIES_MIN = 3;
    private const DIARY_MOVIES_MAX = 5;

    /** Kalimat review yang dipilih acak. */
    /** Kalimat review yang dipilih acak. */
    private const REVIEW_TEXTS = [
        'Film yang sangat bagus!',
        'Aktingnya luar biasa.',
        'Alurnya seru dan tidak membosankan.',
        'Visualnya memukau dari awal sampai akhir.',
        'Salah satu film terbaik tahun ini.',
        'Soundtrack-nya sangat ikonik.',
        'Bikin nangis di bagian akhir.',
        'Karakter-karakternya sangat kuat.',
        'Plotnya penuh twist, prediksinya meleset.',
        'Nilai uangnya sepadan dengan tiketnya.',
        'Cinematography-nya bagus banget.',
        'I would watch this again in a heartbeat.',
        'Musiknya nagih dan remaining di kepala.',
        'A hidden gem that more people should see.',
        'Never expected that ending, in the best way.',
        'Sangat engaging dari menit pertama.',
        'Visualnya ikonik dan sangat berani.',
        'Genre-nya unik, tidak seperti film lain.',
        'Penonton baru pasti suka.',
        'Recommended! Nggak ada yang salah.',
    ];

    private const DIARY_NOTES = [
        'Nonton jam malam,surprisingly nagih.',
        'Ternyata lebih enak dari yang kuira.',
        'Nonton bareng teman, seru banget.',
        'Ulang tayang kedua, tetap bagus.',
        'Akhirnya nonton juga nih.',
        'Recommended sama temen!',
    ];

    public function run(): void
    {
        $movieIds = Movie::query()->pluck('id')->all();

        if ($movieIds === []) {
            $this->command?->warn('Belum ada film. Jalankan MovieSeeder dulu.');
            $this->command?->warn('Contoh: php artisan db:seed --class=MovieSeeder');

            return;
        }

        $this->seedUsers();
        $userIds = User::query()->where('role', 'user')->pluck('id')->all();

        if ($userIds === []) {
            $this->command?->warn('Tidak ada user dengan role user.');

            return;
        }

        $this->seedReviews($movieIds, $userIds);
        $this->seedLikes($movieIds, $userIds);
        $this->seedDiary($movieIds, $userIds);

        $this->command?->info('Selesai. Data dummy sudah dibuat.');
    }

    /**
     * Buat user palsu lewat UserFactory bawaan Laravel.
     */
    private function seedUsers(): void
    {
        User::factory()
            ->count(self::USER_COUNT)
            ->create();

        $this->command?->info('User palsu: '.self::USER_COUNT);
    }

    /**
     * Setiap film direview oleh 30-50 user dengan rating 3-5.
     */
    private function seedReviews(array $movieIds, array $userIds): void
    {
        $rows = [];
        $now = now();

        foreach ($movieIds as $movieId) {
            $reviewers = $this->pickUsers($userIds, self::REVIEWERS_MIN, self::REVIEWERS_MAX);

            foreach ($reviewers as $userId) {
                $rows[] = [
                    'user_id' => $userId,
                    'movie_id' => $movieId,
                    'rating' => random_int(3, 5),
                    'content' => self::REVIEW_TEXTS[array_rand(self::REVIEW_TEXTS)],
                    'created_at' => $now,
                    'updated_at' => $now,
                ];
            }
        }

        $inserted = $this->insertInChunks('reviews', $rows);

        $this->command?->info('Review: '.$inserted);
    }

    /**
     * Setiap film liked oleh 20-40 user.
     */
    private function seedLikes(array $movieIds, array $userIds): void
    {
        $rows = [];
        $now = now();

        foreach ($movieIds as $movieId) {
            $likers = $this->pickUsers($userIds, self::LIKERS_MIN, self::LIKERS_MAX);

            foreach ($likers as $userId) {
                $rows[] = [
                    'user_id' => $userId,
                    'likeable_id' => $movieId,
                    'likeable_type' => Movie::class,
                    'created_at' => $now,
                    'updated_at' => $now,
                ];
            }
        }

        $inserted = $this->insertInChunks('likes', $rows);

        $this->command?->info('Like: '.$inserted);
    }

    /**
     * 50 user punya 3-5 film di tabel watched dan diary_entries.
     */
    private function seedDiary(array $movieIds, array $userIds): void
    {
        $watchedRows = [];
        $diaryRows = [];
        $now = now();

        $diaryUsers = $this->pickUsers($userIds, self::DIARY_USERS, self::DIARY_USERS);

        foreach ($diaryUsers as $userId) {
            $count = random_int(self::DIARY_MOVIES_MIN, self::DIARY_MOVIES_MAX);
            $movies = array_slice($movieIds, 0, $count);
            shuffle($movies);

            foreach ($movies as $movieId) {
                $watchedAt = now()->subDays(random_int(0, 365))->toDateString();

                $watchedRows[] = [
                    'user_id' => $userId,
                    'movie_id' => $movieId,
                    'watched_at' => $watchedAt,
                    'created_at' => $now,
                    'updated_at' => $now,
                ];

                $diaryRows[] = [
                    'user_id' => $userId,
                    'movie_id' => $movieId,
                    'watched_date' => $watchedAt,
                    'note' => self::DIARY_NOTES[array_rand(self::DIARY_NOTES)],
                    'created_at' => $now,
                    'updated_at' => $now,
                ];
            }
        }

        $watched = $this->insertInChunks('watched', $watchedRows);
        $diary = $this->insertInChunks('diary_entries', $diaryRows);

        $this->command?->info('Watched: '.$watched);
        $this->command?->info('Diary: '.$diary);
    }

    /**
     * Pilih beberapa user secara acak tanpa duplikat.
     *
     * @param  array<int, int>  $userIds
     * @return array<int, int>
     */
    private function pickUsers(array $userIds, int $min, int $max): array
    {
        $count = min(random_int($min, $max), count($userIds));

        $picked = array_rand($userIds, $count);

        return array_map(fn ($index) => $userIds[$index], $picked);
    }

    /**
     * Sisipkan baris per bagian, lewati yang melanggar unique constraint.
     *
     * @param  array<int, array<string, mixed>>  $rows
     * @return int  jumlah baris yang benar-benar tersimpan
     */
    private function insertInChunks(string $table, array $rows): int
    {
        $inserted = 0;

        foreach (array_chunk($rows, 500) as $chunk) {
            $inserted += DB::table($table)->insertOrIgnore($chunk);
        }

        return $inserted;
    }
}
