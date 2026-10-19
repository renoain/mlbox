# MLBOX PROJECT OVERVIEW

Dokumen ini adalah sumber kebenaran proyek MLBox untuk bagian
tujuan, fitur, alur aplikasi, navigasi, UI, arsitektur, dan kontrak
API. Jika kode berbeda dengan dokumen ini, perbaiki kode kecuali
dokumen ini diperbarui lebih dulu.

## 1. Identitas Proyek

- Nama: MLBox
- Referensi: Letterboxd (film diary + social catalog)
- Platform: Flutter (mobile) + Laravel REST API + MySQL
- Root workspace: D:/project/mlbox/
- Lokasi Flutter: D:/project/mlbox/mlbox/
- Lokasi Laravel: D:/project/mlbox/server/
- Dokumentasi: D:/project/mlbox/docs/

## 2. Tujuan

Aplikasi pencatatan film dan katalog film sederhana dengan
referensi Letterboxd. Pengguna dapat melihat katalog film,
menyimpan film ke watchlist, mencatat film yang sudah ditonton,
memberi rating dan review, serta melihat profil sendiri. Admin
dapat menambah film ke katalog.

## 3. Ruang Lingkup MVP

Fitur yang MASUK MVP:

1. Autentikasi: register, login, logout
2. Katalog film: daftar film, detail film
3. Watchlist: tambah, lihat, hapus
4. Watched + rating + review: tambah, ubah, lihat, hapus
5. Profil: statistik sederhana, daftar watched dan watchlist
6. Admin: tambah film ke katalog

Fitur yang DITUNDA (jangan dibuat di MVP):

- Diary terpisah (diary digabung ke watched)
- Lists kurasi
- Tags
- Four Favourites
- Like terpisah dari rating
- Follow antar user
- Activity feed
- Komentar review
- Notifikasi
- Moderasi admin
- Upload poster/backdrop (pakai URL eksternal dulu)

## 4. Batasan Arsitektur

Flutter:

- State: flutter_riverpod
- Routing: go_router
- HTTP: dio + interceptor token
- Token storage: flutter_secure_storage
- Image cache: cached_network_image
- Ikon: cupertino_icons

Laravel:

- REST API saja (tanpa Blade)
- Auth: Laravel Sanctum (Bearer token)
- Validasi: FormRequest
- Otorisasi: middleware EnsureUserIsAdmin
- Role disimpan di kolom users.role (enum: user, admin)

MySQL:

- Database: mlbox
- Migration sebagai satu-satunya sumber definisi skema
- Nama tabel plural, snake_case
- Foreign key cascade untuk data user

Aturan keras:

- UI tidak boleh memuat logika HTTP atau akses DB
- Logika API hanya di folder repositories (Flutter)
- State hanya dikelola di providers (Riverpod)
- Semua string user-facing ditaruh di konstanta
- Semua warna, spacing, radius dari app_theme.dart

## 5. Design System

Warna:

- Background: #14181C
- Surface: #1C252E
- Primary / aksen: #00E054
- Text primary: #FFFFFF
- Text secondary: #9AB5C4
- Error: #FF4C4C

Tipografi:

- Font: sistem default (SF Pro / Roboto)
- Caption: 12
- Body: 14
- Subtitle: 16
- Title: 20
- Headline: 28

Spacing: kelipatan 4 (4, 8, 12, 16, 24, 32)

Radius:

- Card: 8
- Sheet: 12
- Tombol pill: 24
- Poster: 4

Komponen reusable wajib:

- MoviePoster: card poster + title + year
- MovieGrid: grid dari MoviePoster
- RatingStars: mode baca dan mode input
- AppBottomNavigation: Home, Discover, Watchlist, Profile
- StateViews: loading, empty, error
- PrimaryButton, SecondaryButton
- CustomTextField

## 6. Application Flow

Tingkat tinggi:

    Launch
      |
      v
    Splash (cek token)
      |
      +-- token valid ------> Home
      |
      +-- token tidak ada --> Login / Register
                                |
                                v
                              Home

Dari Home pengguna dapat:

- tap film -> Detail Film
- tab Discover -> Search
- tab Watchlist -> daftar watchlist
- tab Profile -> profil sendiri

Dari Detail Film pengguna dapat:

- tambah ke Watchlist
- tandai Watched (dengan rating + review opsional)
- ubah/hapus watched

Admin (role admin) dari Home dapat membuka:

- Admin Dashboard -> form tambah film

## 7. Navigation Flow (go_router)

Route list:

| Path              | Halaman           | Akses  |
| ----------------- | ----------------- | ------ |
| /splash           | Splash            | publik |
| /login            | Login             | publik |
| /register         | Register          | publik |
| /home             | Home              | login  |
| /search           | Discover / Search | login  |
| /movie/:id        | Detail Film       | login  |
| /movie/:id/review | Form Review       | login  |
| /watchlist        | Watchlist         | login  |
| /profile          | Profil sendiri    | login  |
| /admin            | Admin Dashboard   | admin  |
| /admin/movies/new | Form Tambah Film  | admin  |

Bottom navigation (hanya muncul saat login):

- Home (index 0) -> /home
- Discover (index 1) -> /search
- Watchlist (index 2) -> /watchlist
- Profile (index 3) -> /profile

Redirect rules (go_router):

- Belum login + buka route privat -> return '/login'
- Sudah login + buka /login atau /register -> return '/home'
- Role user + buka /admin -> return '/home'
- Redirect hanya return string, tidak panggil context.go
- Cek sesi dan role lewat authProvider (Riverpod)

## 8. UI Flow per Halaman

### Splash

- Tujuan: cek token, redirect
- Elemen: logo, nama aplikasi
- State: loading
- Aksi: otomatis redirect setelah cek token

### Login

- Field: email, password
- Tombol: Masuk, link ke Register
- State: kosong, validasi, loading, error, sukses
- Sumber data: POST /api/login

### Register

- Field: name, email, password, password_confirmation
- Tombol: Daftar, link ke Login
- State: kosong, validasi, loading, error, sukses
- Sumber data: POST /api/register

### Home

- Tujuan: beranda daftar film
- Elemen: search bar (dekoratif, tap ke /search), grid film
- State: loading, data, kosong, error
- Sumber data: GET /api/movies
- Aksi: tap film ke /movie/:id

### Search

- Elemen: search bar aktif, grid film
- Sumber data: GET /api/movies?q=
- State: belum ada query, searching, hasil, tidak ditemukan, error

### Detail Film

- Elemen: poster besar, judul, tahun, genre, sinopsis,
  sutradara, aktor
- Tombol: Tambah ke Watchlist / Hapus dari Watchlist,
  Tandai Watched / Ubah Watched
- Info: rating user saat ini jika sudah watched
- Sumber data: GET /api/movies/:id, GET /api/watchlist,
  GET /api/watched
- State: loading, data, error, film tidak ada

### Form Review (rate + review)

- Elemen: rating stars 1-5, field review teks, tombol Simpan
- Sumber data: POST /api/watched atau PUT /api/watched/:id
- State: kosong, validasi, loading, error, sukses

### Watchlist

- Elemen: grid film watchlist
- Aksi: tap ke Detail, hapus dari watchlist dengan konfirmasi
- Sumber data: GET /api/watchlist, DELETE /api/watchlist/:movie_id
- State: loading, data, kosong, error

### Profile

- Elemen: nama, email, statistik (jumlah watched, watchlist)
- Sub-tab sederhana: Watched, Watchlist
- Tombol: Logout
- Sumber data: GET /api/watched, GET /api/watchlist
- State: loading, data, error

### Admin Dashboard

- Elemen: daftar film, tombol Tambah Film
- Aksi: buka form tambah film
- Sumber data: GET /api/movies
- State: loading, data, kosong, error

## 9. Struktur Folder Flutter

Target struktur (dibuat bertahap, tidak sekaligus):

    lib/
      main.dart
      core/
        api_client.dart        # Dio + interceptor token
        app_router.dart        # go_router config + redirect
        app_theme.dart         # warna, teks, spacing token
        storage.dart           # flutter_secure_storage wrapper
      models/
        user.dart
        movie.dart
        watched_entry.dart
      providers/
        auth_provider.dart
        movie_provider.dart
        watchlist_provider.dart
        watched_provider.dart
      repositories/
        auth_repository.dart
        movie_repository.dart
        watchlist_repository.dart
        watched_repository.dart
        admin_repository.dart
      pages/
        splash_page.dart
        login_page.dart
        register_page.dart
        home_page.dart
        search_page.dart
        movie_detail_page.dart
        review_form_page.dart
        watchlist_page.dart
        profile_page.dart
        admin_dashboard_page.dart
      widgets/
        movie_poster.dart
        movie_grid.dart
        rating_stars.dart
        app_bottom_navigation.dart
        state_views.dart

Catatan: folder lib/ saat ini hanya berisi main.dart. Folder di atas
dibuat saat fitur terkait dikerjakan, bukan di awal.

## 10. Struktur Folder Laravel (server/)

Target struktur:

    app/
      Http/
        Controllers/Api/
          AuthController.php
          MovieController.php
          WatchlistController.php
          WatchedController.php
          AdminMovieController.php
        Middleware/
          EnsureUserIsAdmin.php
        Requests/
          RegisterRequest.php
          LoginRequest.php
          StoreMovieRequest.php
          StoreWatchedRequest.php
      Models/
        User.php
        Movie.php
        Watchlist.php
        Watched.php
    database/
      migrations/
      seeders/
        AdminSeeder.php
        MovieSeeder.php
    routes/
      api.php

## 11. Kontrak REST API

Base URL: http://127.0.0.1:8000/api
Android emulator: http://10.0.2.2:8000/api

Format response konsisten:

Sukses:

    { "success": true, "data": ..., "message": "..." }

Error:

    { "success": false, "message": "...", "errors": { "field": ["..."] } }

### Auth

POST /register
Body: { name, email, password, password_confirmation }
Response 201: { success: true, data: { user: {id,name,email,role}, token } }
Error 422: validasi gagal

POST /login
Body: { email, password }
Response 200: { success: true, data: { user: {id,name,email,role}, token } }
Error 401: { success: false, message: "Invalid credentials" }

POST /logout (auth:sanctum)
Response 200: { success: true, message: "Logged out" }

### Movies

GET /movies?q=&page=
Response 200: { success: true, data: [ {id,title,year,poster_url,genre} ], meta: {current_page, last_page, total} }

GET /movies/{id}
Response 200: { success: true, data: {id,title,synopsis,poster_url,year,director,actors,genre} }
Error 404: { success: false, message: "Movie not found" }

### Watchlist (auth:sanctum)

GET /watchlist
Response 200: { success: true, data: [movie...] }

POST /watchlist
Body: { movie_id }
Response 201: { success: true, message: "Added to watchlist" }
Error 422: sudah ada di watchlist

DELETE /watchlist/{movie_id}
Response 200: { success: true, message: "Removed from watchlist" }
Error 404: tidak ada di watchlist

### Watched (auth:sanctum)

GET /watched
Response 200: { success: true, data: [ {movie..., rating, review, watched_at} ] }

POST /watched
Body: { movie_id, rating?, review?, watched_at? }
Response 201: { success: true, data: watched_row }
Error 422: sudah watched, atau rating di luar 1-5

PUT /watched/{movie_id}
Body: { rating?, review?, watched_at? }
Response 200: { success: true, data: watched_row }
Error 404: belum watched

DELETE /watched/{movie_id}
Response 200: { success: true, message: "Removed from watched" }

### Admin (auth:sanctum + EnsureUserIsAdmin)

POST /admin/movies
Body: { title, synopsis?, poster_url?, year?, director?, actors?, genre? }
Response 201: { success: true, data: movie }
Error 403: { success: false, message: "Forbidden" }
Error 422: validasi gagal

## 12. Autentikasi dan Token

Flow:

1. Login berhasil -> backend kirim plainTextToken (Sanctum)
2. Flutter simpan ke flutter_secure_storage, key: auth_token
3. Dio interceptor menambahkan header Authorization: Bearer <token>
4. Setiap request ke endpoint privat lewat interceptor

Penanganan HTTP error:

- 401 -> hapus token lokal, redirect ke /login
- 403 -> tampilkan "Akses ditolak", tidak redirect
- 422 -> tampilkan errors per field di form
- 429 -> tampilkan "Terlalu banyak permintaan, coba lagi nanti"
- 500 -> tampilkan "Terjadi kesalahan server"

Tidak memakai refresh token di MVP. Token expired -> login ulang.

## 13. Aturan Perubahan

- Kontrak API di Bab 11 tidak boleh diubah tanpa update dokumen ini
- Skema DB di DATABASE_SCHEMA.md tidak boleh diubah tanpa migration
  baru + update dokumen
- Jangan tambah tabel/fitur di luar Bab 3 tanpa update dokumen ini
- Fitur yang sudah berjalan tidak boleh dihapus saat perbaiki fitur lain
- Setiap akhir sesi: perbarui PROGRESS.md
