<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Genre;
use App\Models\Movie;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use ZipArchive;

// Import banyak film sekaligus dari file zip berisi movies.json.
class MovieBatchImportService
{
    // Struktur zip: movies.json di root dan folder posters/ opsional.
    public function import(UploadedFile $zip, int $adminId): array
    {
        $extractPath = 'batch-imports/'.Str::uuid()->toString();
        $fullPath = Storage::path($extractPath);
        mkdir($fullPath, 0755, true);

        $archive = new ZipArchive();
        $archive->open($zip->getRealPath());
        $archive->extractTo($fullPath);
        $archive->close();

        $jsonPath = $fullPath.'/movies.json';

        if (! is_file($jsonPath)) {
            return ['created' => 0, 'failed' => 0, 'unmatched' => [], 'errors' => ['movies.json tidak ditemukan di dalam zip.']];
        }

        $entries = json_decode((string) file_get_contents($jsonPath), true);

        if (! is_array($entries)) {
            return ['created' => 0, 'failed' => 0, 'unmatched' => [], 'errors' => ['movies.json bukan JSON array yang valid.']];
        }

        $created = 0;
        $failed = 0;
        $unmatched = [];
        $errors = [];

        foreach ($entries as $index => $entry) {
            if (! is_array($entry) || empty($entry['title'])) {
                $failed++;
                $errors[] = 'Baris '.($index + 1).': judul wajib diisi.';

                continue;
            }

            $posterFile = $this->findPoster($fullPath, (string) $entry['title'], $entry['poster_filename'] ?? null);

            if ($posterFile === null && ! empty($entry['poster_filename'] ?? null)) {
                $unmatched[] = ['title' => $entry['title'], 'poster_filename' => $entry['poster_filename']];
            }

            try {
                DB::transaction(function () use ($entry, $posterFile, $adminId): void {
                    $movie = Movie::create([
                        'title' => $entry['title'],
                        'original_title' => $entry['original_title'] ?? null,
                        'overview' => $entry['overview'] ?? null,
                        'release_date' => $entry['release_date'] ?? null,
                        'runtime' => $entry['runtime'] ?? null,
                        'language' => $entry['language'] ?? null,
                        'country' => $entry['country'] ?? null,
                        'cast' => $entry['cast'] ?? null,
                        'crew' => $entry['crew'] ?? null,
                        'is_featured' => (bool) ($entry['is_featured'] ?? false),
                        'poster_path' => $posterFile !== null ? $this->storePoster($posterFile) : null,
                    ]);

                    $genreIds = [];

                    foreach ((array) ($entry['genres'] ?? []) as $name) {
                        $genreIds[] = $this->findOrCreateGenre((string) $name)->id;
                    }

                    $movie->genres()->sync($genreIds);

                    app(AdminAuditService::class)->log($adminId, 'create', 'movie', $movie->id, ['title' => $movie->title, 'source' => 'batch']);
                });

                $created++;
            } catch (\Throwable $e) {
                $failed++;
                $errors[] = 'Baris '.($index + 1).': gagal menyimpan film.';
            }
        }

        Storage::deleteDirectory($extractPath);

        return ['created' => $created, 'failed' => $failed, 'unmatched' => $unmatched, 'errors' => $errors];
    }

    // Pemetaan manual poster yang tidak cocok otomatis.
    public function resolve(array $mapping): void
    {
        foreach ($mapping as $movieId => $filename) {
            $movie = Movie::find((int) $movieId);

            if ($movie === null || ! is_file((string) $filename)) {
                continue;
            }

            $movie->update(['poster_path' => $this->storePoster((string) $filename)]);
        }
    }

    private function findPoster(string $basePath, string $title, ?string $hint): ?string
    {
        $postersPath = $basePath.'/posters';

        if (! is_dir($postersPath)) {
            return null;
        }

        if ($hint !== null && is_file($postersPath.'/'.$hint)) {
            return $postersPath.'/'.$hint;
        }

        $normalized = $this->normalize($title);

        foreach ((array) glob($postersPath.'/*.{jpg,jpeg,png,webp}', GLOB_BRACE) as $file) {
            if ($this->normalize((string) pathinfo($file, PATHINFO_FILENAME)) === $normalized) {
                return $file;
            }
        }

        return null;
    }

    private function storePoster(string $sourcePath): string
    {
        $name = 'posters/'.Str::uuid()->toString().'.'.pathinfo($sourcePath, PATHINFO_EXTENSION);

        Storage::disk('public')->put($name, (string) file_get_contents($sourcePath));

        return $name;
    }

    private function findOrCreateGenre(string $name): Genre
    {
        $slug = Str::slug($name);

        return Genre::firstOrCreate(['slug' => $slug], ['name' => $name]);
    }

    private function normalize(string $value): string
    {
        $value = strtolower($value);
        $value = (string) preg_replace('/\s*\(\d{4}\)/', '', $value);
        $value = (string) preg_replace('/[^a-z0-9]/', '', $value);

        return $value;
    }
}
