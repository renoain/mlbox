<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('list_items', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('list_id')->constrained('lists')->cascadeOnDelete();
            $table->foreignId('movie_id')->constrained('movies')->cascadeOnDelete();
            $table->text('note')->nullable();
            $table->integer('order_index')->default(0);
            $table->timestamps();

            $table->unique(['list_id', 'movie_id']);
            $table->index(['list_id', 'order_index']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('list_items');
    }
};
