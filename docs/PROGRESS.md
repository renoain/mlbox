# MLBOX PROGRESS

Catatan kerja proyek MLBox. Diperbarui setiap akhir sesi.
PROJECT_OVERVIEW.md = kondisi yang dituju.
PROGRESS.md = kondisi aktual saat ini.

## Cara Memakai Dokumen Ini

Jika membuka sesi baru atau konteks AI terputus:

1. Baca PROJECT_OVERVIEW.md dan DATABASE_SCHEMA.md dulu
2. Baca bagian "Status Terakhir" di bawah
3. Periksa file yang disebut di "File yang Sudah Diubah"
4. Lanjutkan dari "Langkah Selanjutnya"
5. Jangan ubah arsitektur di PROJECT_OVERVIEW.md tanpa alasan

## Status Terakhir

Tanggal update: 2026-10-19
Tahap aktif: Fase 0 - Setup dokumen dan fondasi
Status: in progress

## Checklist Fitur MVP

### Fase 0: Setup

- [x] Flutter project dibuat di D:/project/mlbox/mlbox/
- [x] pubspec.yaml final (riverpod, go_router, dio, secure_storage,
      cached_network_image, cupertino_icons)
- [ ] flutter pub get berhasil
- [x] docs/PROJECT_OVERVIEW.md dibuat
- [x] docs/DATABASE_SCHEMA.md dibuat
- [x] docs/PROGRESS.md dibuat

### Fase 1: Server Laravel

- [ ] Buat proyek Laravel di server/
- [ ] Konfigurasi .env (DB mlbox)
- [ ] php artisan key:generate
- [ ] php artisan install:api (Sanctum)
- [ ] Migration: add_role_to_users
- [ ] Migration: movies
- [ ] Migration: watchlist
- [ ] Migration: watched
- [x] Model User, Movie, Watchlist, Watched + relasi
- [ ] AdminSeeder + MovieSeeder
- [ ] AuthController (register, login, logout)
- [ ] MovieController (index, show)
- [ ] WatchlistController (index, store, destroy)
- [ ] WatchedController (index, store, update, destroy)
- [ ] AdminMovieController (store)
- [ ] Middleware EnsureUserIsAdmin
- [ ] routes/api.php final
- [ ] Uji semua endpoint via curl/Postman

### Fase 2: Flutter

- [ ] core/api_client.dart (Dio + interceptor)
- [ ] core/storage.dart (secure storage)
- [ ] core/app_theme.dart
- [ ] core/app_router.dart (go_router + redirect)
- [ ] models: User, Movie, WatchedEntry
- [ ] repositories: Auth, Movie, Watchlist, Watched, Admin
- [ ] providers: AuthProvider, MovieProvider, dll
- [ ] pages: Splash, Login, Register
- [ ] pages: Home, Search, Detail Film
- [ ] pages: Review Form
- [ ] pages: Watchlist, Profile
- [ ] pages: Admin Dashboard
- [ ] widgets: MoviePoster, MovieGrid, RatingStars, StateViews
- [ ] Uji alur penuh end-to-end

### Fase 3: Polish

- [ ] Konsistensi tema di semua halaman
- [ ] Error handling penuh (401, 403, 422, 500)
- [ ] Empty state di setiap halaman
- [ ] Pengujian manual alur lengkap

## File yang Sudah Diubah/Dibuat

Flutter (D:/project/mlbox/mlbox/):

- pubspec.yaml (final dependencies)

Server (D:/project/mlbox/server/):

- (belum ada)

Dokumentasi (D:/project/mlbox/docs/):

- PROJECT_OVERVIEW.md (dibuat)
- DATABASE_SCHEMA.md (dibuat)
- PROGRESS.md (dibuat)

## Hasil Pengujian Terakhir

Format: Endpoint atau Halaman -> hasil

- (belum ada pengujian; Fase 0 baru setup dokumen)

## Bug / Masalah Aktif

Tidak ada bug aktif.

## Langkah Selanjutnya

1. Jalankan flutter pub get di D:/project/mlbox/mlbox/
2. Buat proyek Laravel di D:/project/mlbox/server/ (Fase 1 Langkah 1)
3. Konfigurasi .env untuk database mlbox
4. Jalankan php artisan key:generate dan php artisan install:api

## Catatan Konteks untuk Sesi Berikutnya

Terakhir mengerjakan Fase 0 (setup dokumen). Filetree Flutter
sudah ada di D:/project/mlbox/mlbox/ dengan lib/ hanya berisi
main.dart. Dokumen di D:/project/mlbox/docs/ sudah dibuat.
Langkah selanjutnya: buat proyek Laravel di D:/project/mlbox/server/.

Tanggal update: 2026-10-19
Tahap aktif: Fase 1 - Model dan relasi selesai
Status: in progress
