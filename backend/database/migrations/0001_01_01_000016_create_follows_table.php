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
        Schema::create('follows', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('follower_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('following_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['follower_id', 'following_id']);
            $table->index('following_id');
        });

        // SQLite tidak mendukung ALTER TABLE ADD CONSTRAINT; validasi utama ada di controller.
        if (DB::getDriverName() === 'mysql') {
            DB::statement("alter table `follows` add constraint `follows_self_check` check (`follower_id` <> `following_id`)");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('follows');
    }
};
