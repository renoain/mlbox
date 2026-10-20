<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Satu film boleh punya banyak entri diary selama tanggalnya berbeda.
        $hasOld = DB::select(
            "SHOW INDEX FROM diary_entries WHERE Key_name = 'diary_entries_user_id_movie_id_unique'"
        );
        if (! empty($hasOld)) {
            Schema::table('diary_entries', function (Blueprint $table): void {
                $table->dropUnique(['user_id', 'movie_id']);
            });
        }

        $hasNew = DB::select(
            "SHOW INDEX FROM diary_entries WHERE Key_name = 'diary_entries_user_id_movie_id_watched_date_unique'"
        );
        if (empty($hasNew)) {
            Schema::table('diary_entries', function (Blueprint $table): void {
                $table->unique(['user_id', 'movie_id', 'watched_date']);
            });
        }
    }

    public function down(): void
    {
        $hasNew = DB::select(
            "SHOW INDEX FROM diary_entries WHERE Key_name = 'diary_entries_user_id_movie_id_watched_date_unique'"
        );
        if (! empty($hasNew)) {
            Schema::table('diary_entries', function (Blueprint $table): void {
                $table->dropUnique(['user_id', 'movie_id', 'watched_date']);
            });
        }

        $hasOld = DB::select(
            "SHOW INDEX FROM diary_entries WHERE Key_name = 'diary_entries_user_id_movie_id_unique'"
        );
        if (empty($hasOld)) {
            Schema::table('diary_entries', function (Blueprint $table): void {
                $table->unique(['user_id', 'movie_id']);
            });
        }
    }
};
