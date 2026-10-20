<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('diary_entries', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('movie_id')->constrained('movies')->cascadeOnDelete();
            $table->date('watched_date');
            $table->text('note')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'movie_id']);
            $table->index(['user_id', 'watched_date']);
            $table->index('movie_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('diary_entries');
    }
};
