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
        Schema::create('reviews', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('movie_id')->constrained('movies')->cascadeOnDelete();
            $table->unsignedTinyInteger('rating');
            $table->text('content')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'movie_id']);
            $table->index('movie_id');
        });

        // SQLite tidak mendukung ALTER TABLE ADD CONSTRAINT; validasi utama ada di FormRequest.
        if (DB::getDriverName() === 'mysql') {
            DB::statement("alter table `reviews` add constraint `reviews_rating_check` check (`rating` between 1 and 5)");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
