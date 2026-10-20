<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Rating boleh null supaya unrate bisa menghapus bintang tanpa menghapus teks review.
        Schema::table('reviews', function (Blueprint $table): void {
            $table->unsignedTinyInteger('rating')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('reviews', function (Blueprint $table): void {
            $table->unsignedTinyInteger('rating')->nullable(false)->change();
        });
    }
};
