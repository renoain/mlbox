<?php

declare(strict_types=1);

use App\Models\Movie;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('likes', 'likeable_id')) {
            // Skema polymorphic sudah diterapkan, lewati migrasi.
            return;
        }

        // SQLite tidak bisa menjatuhkan kolom yang dirujuk foreign key,
        // jadi tabel dibuat ulang. Tabel test selalu kosong saat migrasi berjalan.
        if (Schema::getConnection()->getDriverName() === 'sqlite') {
            Schema::dropIfExists('likes');
            $this->createLikes();

            return;
        }

        Schema::table('likes', function (Blueprint $table): void {
            // Index penyangga untuk foreign key user_id setelah unique lama dijatuhkan.
            $table->index('user_id');
            $table->dropUnique(['user_id', 'movie_id']);
            $table->foreignId('likeable_id')->nullable();
            $table->string('likeable_type')->nullable();
        });

        // Data like film lama dipindah ke kolom polymorphic sebelum movie_id dihapus.
        DB::table('likes')->whereNotNull('movie_id')->update(['likeable_type' => Movie::class]);
        DB::table('likes')->whereNotNull('movie_id')
            ->update(['likeable_id' => DB::raw('movie_id')]);

        Schema::table('likes', function (Blueprint $table): void {
            $table->dropForeign(['movie_id']);
            $table->dropIndex(['movie_id']);
            $table->dropColumn('movie_id');
        });

        Schema::table('likes', function (Blueprint $table): void {
            $table->foreignId('likeable_id')->nullable(false)->change();
            $table->string('likeable_type')->nullable(false)->change();
            $table->unique(['user_id', 'likeable_id', 'likeable_type']);
            $table->index(['likeable_type', 'likeable_id']);
        });
    }

    public function down(): void
    {
        if (Schema::getConnection()->getDriverName() === 'sqlite') {
            Schema::dropIfExists('likes');
            $this->createLegacyLikes();

            return;
        }

        Schema::table('likes', function (Blueprint $table): void {
            $table->dropUnique(['user_id', 'likeable_id', 'likeable_type']);
            $table->dropIndex(['likeable_type', 'likeable_id']);
        });

        // Hanya like film yang bisa dikembalikan; like review dan list dibuang.
        DB::table('likes')->where('likeable_type', '!=', Movie::class)->delete();

        Schema::table('likes', function (Blueprint $table): void {
            $table->unsignedBigInteger('movie_id')->nullable();
        });

        DB::table('likes')->update(['movie_id' => DB::raw('likeable_id')]);

        Schema::table('likes', function (Blueprint $table): void {
            $table->dropColumn(['likeable_id', 'likeable_type']);
        });

        Schema::table('likes', function (Blueprint $table): void {
            $table->unsignedBigInteger('movie_id')->nullable(false)->change();
            $table->index('movie_id');
            $table->foreign('movie_id')->references('id')->on('movies')->cascadeOnDelete();
            $table->unique(['user_id', 'movie_id']);
        });
    }

    private function createLikes(): void
    {
        Schema::create('likes', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedBigInteger('likeable_id');
            $table->string('likeable_type');
            $table->timestamps();

            $table->unique(['user_id', 'likeable_id', 'likeable_type']);
            $table->index(['likeable_type', 'likeable_id']);
        });
    }

    private function createLegacyLikes(): void
    {
        Schema::create('likes', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('movie_id')->constrained('movies')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['user_id', 'movie_id']);
            $table->index('movie_id');
        });
    }
};
