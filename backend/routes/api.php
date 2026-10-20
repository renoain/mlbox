<?php

declare(strict_types=1);

use App\Http\Controllers\Api\Admin\AdminAuditLogController;
use App\Http\Controllers\Api\Admin\AdminDashboardController;
use App\Http\Controllers\Api\Admin\AdminGenreController;
use App\Http\Controllers\Api\Admin\AdminListController;
use App\Http\Controllers\Api\Admin\AdminMovieController;
use App\Http\Controllers\Api\Admin\AdminReviewController;
use App\Http\Controllers\Api\Admin\AdminTagController;
use App\Http\Controllers\Api\Admin\AdminUserController;
use App\Http\Controllers\Api\Admin\AdminMovieBatchController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\DiaryController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\FeedController;
use App\Http\Controllers\Api\FollowController;
use App\Http\Controllers\Api\GenreController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\IncomingActivityController;
use App\Http\Controllers\Api\LikeController;
use App\Http\Controllers\Api\ListController;
use App\Http\Controllers\Api\LogController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\MovieController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\PublicProfileController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\TagController;
use App\Http\Controllers\Api\WatchedController;
use App\Http\Controllers\Api\WatchlistController;
use Illuminate\Support\Facades\Route;

/*
| Endpoint katalog film tetap publik supaya tamu bisa melihat isi
| katalog tanpa login. Halamannya sendiri tetap route privat karena
| memerlukan state user.
*/

Route::middleware('throttle:movies')->group(function (): void {
    Route::get('movies', [MovieController::class, 'index']);
    Route::get('movies/{id}', [MovieController::class, 'show']);
    Route::get('genres', [GenreController::class, 'index']);
});

/*
| Endpoint publik profil user lain dipakai halaman followers,
| following, dan public profile.
*/

Route::middleware(['auth:sanctum', 'throttle:api'])->group(function (): void {
    Route::get('users/{userId}', [PublicProfileController::class, 'show']);
    Route::get('users/{userId}/watched', [PublicProfileController::class, 'watched']);

    Route::middleware('throttle:social')->group(function (): void {
        Route::get('followers', [FollowController::class, 'followers']);
        Route::get('following', [FollowController::class, 'following']);
        Route::get('feed', [FeedController::class, 'index']);
        Route::get('activity/incoming', [IncomingActivityController::class, 'index']);
        Route::get('members', [MemberController::class, 'index']);
        Route::get('notifications', [NotificationController::class, 'index']);
    });
});

/*
| Area admin memakai dua lapis middleware. Request tanpa token
| menjawab 401, token valid dengan role user menjawab 403.
*/

Route::middleware(['auth:sanctum', 'role:admin', 'throttle:admin'])
    ->prefix('admin')
    ->group(function (): void {
        Route::get('dashboard', [AdminDashboardController::class, 'index']);

        Route::get('movies', [AdminMovieController::class, 'index']);
        Route::post('movies', [AdminMovieController::class, 'store']);
        Route::put('movies/{id}', [AdminMovieController::class, 'update']);
        Route::delete('movies/{id}', [AdminMovieController::class, 'destroy']);
        Route::post('movies/{id}/restore', [AdminMovieController::class, 'restore']);
        Route::post('movies/{id}/feature', [AdminMovieController::class, 'toggleFeature']);
        Route::post('movies/batch-import', [AdminMovieBatchController::class, 'import']);
        Route::post('movies/batch-resolve', [AdminMovieBatchController::class, 'resolve']);

        Route::get('genres', [AdminGenreController::class, 'index']);
        Route::post('genres', [AdminGenreController::class, 'store']);
        Route::put('genres/{id}', [AdminGenreController::class, 'update']);
        Route::delete('genres/{id}', [AdminGenreController::class, 'destroy']);

        Route::get('users', [AdminUserController::class, 'index']);
        Route::get('users/{id}', [AdminUserController::class, 'show']);
        Route::put('users/{id}/role', [AdminUserController::class, 'updateRole']);

        Route::get('reviews', [AdminReviewController::class, 'index']);
        Route::delete('reviews/{id}', [AdminReviewController::class, 'destroy']);

        Route::get('lists', [AdminListController::class, 'index']);
        Route::delete('lists/{id}', [AdminListController::class, 'destroy']);

        Route::get('tags', [AdminTagController::class, 'index']);
        Route::delete('tags/{id}', [AdminTagController::class, 'destroy']);

        Route::get('audit-logs', [AdminAuditLogController::class, 'index']);
    });

Route::middleware(['throttle:auth'])->group(function (): void {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
});

Route::middleware(['auth:sanctum', 'throttle:api'])->group(function (): void {
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'me']);

    Route::get('home', [HomeController::class, 'index']);

    Route::middleware('throttle:write')->group(function (): void {
        Route::get('watchlist', [WatchlistController::class, 'index']);
        Route::post('watchlist', [WatchlistController::class, 'store']);
        Route::delete('watchlist/{movieId}', [WatchlistController::class, 'destroy']);

        Route::get('watched', [WatchedController::class, 'index']);
        Route::post('watched', [WatchedController::class, 'store']);
        Route::patch('watched/{movieId}', [WatchedController::class, 'update']);
        Route::delete('watched/{movieId}', [WatchedController::class, 'destroy']);

        Route::get('reviews', [ReviewController::class, 'index']);
        Route::post('reviews', [ReviewController::class, 'store']);
        Route::put('reviews/{id}', [ReviewController::class, 'update']);
        Route::delete('reviews/{id}', [ReviewController::class, 'destroy']);

        Route::get('reviews/{reviewId}/comments', [CommentController::class, 'index']);
        Route::post('reviews/{reviewId}/comments', [CommentController::class, 'store']);
        Route::delete('comments/{id}', [CommentController::class, 'destroy']);

        Route::get('diary', [DiaryController::class, 'index']);
        Route::post('diary', [DiaryController::class, 'store']);
        Route::put('diary/{id}', [DiaryController::class, 'update']);
        Route::delete('diary/{id}', [DiaryController::class, 'destroy']);
        Route::post('diary/{id}/tags', [TagController::class, 'attachToDiary']);
        Route::delete('diary/{id}/tags/{tagId}', [TagController::class, 'detachFromDiary']);

        Route::get('lists', [ListController::class, 'index']);
        Route::post('lists', [ListController::class, 'store']);
        Route::get('lists/{id}', [ListController::class, 'show']);
        Route::put('lists/{id}', [ListController::class, 'update']);
        Route::delete('lists/{id}', [ListController::class, 'destroy']);
        Route::post('lists/{id}/items', [ListController::class, 'storeItem']);
        Route::patch('lists/{id}/items', [ListController::class, 'updateItems']);
        Route::delete('lists/{id}/items/{movieId}', [ListController::class, 'destroyItem']);

        Route::get('tags', [TagController::class, 'index']);
        Route::post('tags', [TagController::class, 'store']);
        Route::delete('tags/{id}', [TagController::class, 'destroy']);

        Route::get('favorites', [FavoriteController::class, 'index']);
        Route::put('favorites', [FavoriteController::class, 'update']);

        Route::post('likes', [LikeController::class, 'store']);
        Route::delete('likes', [LikeController::class, 'destroy']);
        Route::get('likes', [LikeController::class, 'index']);
        Route::get('likes/{movieId}', [LikeController::class, 'show']);

        Route::post('movies/{id}/rate', [MovieController::class, 'rate']);
        Route::delete('movies/{id}/rate', [MovieController::class, 'unrate']);

        Route::put('notifications/{id}/read', [NotificationController::class, 'markRead']);
        Route::put('notifications/read-all', [NotificationController::class, 'markAllRead']);

        Route::post('follow/{userId}', [FollowController::class, 'store']);
        Route::delete('follow/{userId}', [FollowController::class, 'destroy']);

        Route::post('log', [LogController::class, 'store']);
    });

    Route::get('profile', [ProfileController::class, 'show']);
    Route::get('profile/stats', [ProfileController::class, 'stats']);
    Route::get('profile/reviews', [ProfileController::class, 'reviews']);
});