<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\DiaryEntry;
use App\Models\Watched;
use Illuminate\Support\Facades\DB;

/**
 * Menjaga konsistensi antara tabel `watched` dan `diary_entries`.
 *
 * Di Letterboxd, film yang ditandai "watched" otomatis masuk ke log pada
 * tanggal yang sama. Karena itu kedua tabel harus selalu ditulis
 * bersamaan: tidak boleh ada film yang watched tapi tidak punya entri log
 * (dan sebaliknya).
 *
 * Batasan unik `watched` adalah (user_id, movie_id) dan `diary_entries`
 * adalah (user_id, movie_id, watched_date), jadi film yang sama boleh punya
 * beberapa entri log pada tanggal berbeda, tapi hanya satu baris watched.
 */
class WatchLogService
{
    /**
     * Tandai film sudah ditonton pada tanggal tertentu.
     *
     * Membuat baris `watched` (kalau belum ada) dan entri log pada tanggal
     * yang sama, supaya film langsung muncul di halaman Log.
     *
     * @return array{watched: Watched, entry: DiaryEntry}
     */
    public function markWatched(int $userId, int $movieId, string $date, ?string $note = null): array
    {
        return DB::transaction(function () use ($userId, $movieId, $date, $note): array {
            $watched = Watched::firstOrNew([
                'user_id' => $userId,
                'movie_id' => $movieId,
            ]);

            if (! $watched->exists) {
                $watched->watched_at = $date;
                $watched->save();
            }

            // Entri log untuk tanggal yang sama dibuat hanya kalau belum ada,
            // supaya catatan yang sudah ada tidak tertimpa.
            $entry = DiaryEntry::firstOrCreate(
                [
                    'user_id' => $userId,
                    'movie_id' => $movieId,
                    'watched_date' => $date,
                ],
                ['note' => $note],
            );

            return ['watched' => $watched, 'entry' => $entry];
        });
    }

    /**
     * Batalkan status watched.
     *
     * Menghapus baris `watched` beserta seluruh entri log film tersebut,
     * supaya tidak ada entri log yang tertinggal untuk film yang sudah
     * dibatalkan.
     */
    public function unwatch(int $userId, int $movieId): int
    {
        return DB::transaction(function () use ($userId, $movieId): int {
            $deleted = Watched::where('user_id', $userId)->where('movie_id', $movieId)->delete();

            DiaryEntry::where('user_id', $userId)->where('movie_id', $movieId)->delete();

            return $deleted;
        });
    }

    /**
     * Hapus satu entri log.
     *
     * Baris `watched` ikut dihapus kalau film itu tidak punya entri log
     * lain, supaya kedua tabel tetap konsisten.
     */
    public function deleteDiaryEntry(int $userId, int $entryId): int
    {
        return DB::transaction(function () use ($userId, $entryId): int {
            $entry = DiaryEntry::where('user_id', $userId)->find($entryId);

            if ($entry === null) {
                return 0;
            }

            $movieId = (int) $entry->movie_id;

            $entry->delete();

            $stillLogged = DiaryEntry::where('user_id', $userId)
                ->where('movie_id', $movieId)
                ->exists();

            if (! $stillLogged) {
                Watched::where('user_id', $userId)->where('movie_id', $movieId)->delete();
            }

            return 1;
        });
    }
}
