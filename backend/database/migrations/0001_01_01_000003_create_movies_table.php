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
        Schema::create('movies', function (Blueprint $table): void {
            $table->id();
            $table->string('title', 255);
            $table->string('original_title', 255)->nullable();
            $table->text('overview')->nullable();
            $table->date('release_date')->nullable();
            $table->string('poster_path', 255)->nullable();
            $table->string('backdrop_path', 255)->nullable();
            $table->unsignedInteger('runtime')->nullable();
            $table->string('language', 10)->nullable();
            $table->string('country', 100)->nullable();
            $table->text('cast')->nullable();
            $table->text('crew')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->softDeletes();
            $table->timestamps();

            $table->index(['is_featured', 'deleted_at']);
            $table->index(['deleted_at', 'created_at']);
            $table->index('title');
            $table->index('release_date');
        });

        // SQLite tidak mendukung ALTER TABLE ADD CONSTRAINT; validasi utama ada di FormRequest.
        if (DB::getDriverName() === 'mysql') {
            DB::statement("alter table `movies` add constraint `movies_runtime_check` check (`runtime` is null or `runtime` >= 1)");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('movies');
    }
};
