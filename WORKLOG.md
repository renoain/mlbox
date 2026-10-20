# MLBox — WORKLOG (Root Project Log)

Catatan kerja sesi berjalan. Diperbarui setiap akhir sesi agar sesi
berikutnya tahu **sudah dikerjakan apa** dan **lanjut ke mana**.

- Stack: Flutter (Riverpod, GoRouter 14, Dio, flutter_secure_storage, cached_network_image)
- Backend: Laravel (Sanctum) di `backend/`, base URL `http://127.0.0.1:8000/api`
- Target: Chrome desktop (Windows) & Android
- Tema: background `#14181C`, surface `#1C252E`, primary `#00E054` (gelap ala Letterboxd)

> Catatan: `docs/PROGRESS.md` masih menyebut path lama (`mlbox/mlbox/` dan
> `server/`). Struktur aktual proyek: `D:/project/mlbox/lib/` (Flutter) dan
> `D:/project/mlbox/backend/` (Laravel). Abaikan path lama itu.

---

## Status Terakhir

- Tanggal update: 2026-10-20
- Branch aktif: `feat/review-rating-api`
- Branch `main`: sudah berisi Tahap 1, 2, 3
- Status: Tahap 1–4 sudah di `main`; Tahap 5 (rating di detail) selesai, belum di-commit

---

## Riwayat Commit (main)

| Commit | Isi |
|---|---|
| `cc7fa59` | fix: guest navigation, separate login/register, auth API, layout crash |
| `b99c4a7` | feat: watchlist and watched pages wired to API |

---

## Sudah Dikerjakan

### Tahap 1 — Guest Navigation, Login/Register UI, Crash Fix
- Router tunggal di `lib/main.dart` (hapus duplikat `lib/core/app_router.dart`).
- Rute aktif: `/splash`, `/home`, `/login`, `/register`, `/search`,
  `/watchlist`, `/profile`, `/movie/:id`, `/movie/:id/review`.
- Guest navbar tepat 3 menu: **Users -> /login**, **Films -> /home**, **Search -> /search**.
- Login & Register halaman terpisah; Register dibuka via `push` sehingga back bekerja.
- Hapus dead code: `lib/pages/main_navigation.dart`, `lib/widgets/letterboks_bottom_nav.dart`, `scroll_view_backup.txt`.
- Search memakai `moviesProvider` (API), bukan data dummy.

### Tahap 2 — Autentikasi API
- `LoginPage` & `RegisterPage` -> `authProvider.login/register` (Laravel).
- `ProfilePage` menampilkan user + logout nyata; navbar guest-safe.
- `ApiClient` baseUrl adaptif: `10.0.2.2` untuk Android emulator, `127.0.0.1` untuk web/desktop.
- **Fix crash layout**: tombol dalam `Row` mewarisi tema global
  `minimumSize: Size(double.infinity, 50)` -> assertion `rendering/box.dart` +
  `mouse_tracker.dart` + "Cannot hit test a render box". Solusi: beri
  `minimumSize` eksplisit pada tombol di dalam `Row`.
  (`mouse_tracker`/`box.dart` adalah gejala, bukan akar.)

### Tahap 3 — Watchlist & Watched (API)
- Repository baru: `watchlist_repository.dart`, `watched_repository.dart`.
- Provider baru: `library_provider.dart` (`watchlistProvider`, `watchedProvider`,
  `isInWatchlistProvider(id)`, `isWatchedProvider(id)`).
- `WatchlistPage` menampilkan data API (loading/error/empty); guest diminta login.
- `MovieDetailPage`: tombol WATCHLIST/WATCHED memanggil API, menampilkan status aktif.
- **Perilaku backend penting**: menandai `watched` otomatis menghapus film dari watchlist.

### Tahap 4 — Review & Rating (API)
- Repository baru: `review_repository.dart` (`createReview`, `getMyReviews`).
- Provider baru di `library_provider.dart`: `myReviewsProvider`, `reviewRepositoryProvider`.
- `ReviewFormPage` disambungkan ke `POST /reviews` (bukan simulasi lagi),
  dengan loading state, error handling, dan `ref.invalidate(myReviewsProvider)`.
- Model `Review.fromJson` disesuaikan kontrak `ReviewResource` (`user_name`,
  `movie_id`, `updated_at`); fallback nama `Anonymous`.
- Hapus method usang `MovieRepository.getMovieReviews` + `movieReviewsProvider`
  (menargetkan `GET /movies/{id}/reviews` yang **tidak ada** di backend = bug laten).
- Tombol "TULIS REVIEW" di Detail Film kini guard guest -> SnackBar + "Masuk".

### Tahap 5 — Rating Bintang di Detail Film (API)
- `movie_repository.dart`: `rateMovie(id, rating)` -> `POST /movies/{id}/rate`,
  `unrateMovie(id)` -> `DELETE /movies/{id}/rate`.
- `movie.dart`: tambah `averageRating` (`average_rating`) & `reviewCount`
  (`review_count`); perbaiki parsing `genres` (list objek -> nama).
- `movie_detail_page.dart`: section RATINGS kini menampilkan rata-rata komunitas
  + jumlah review, plus baris "Rating kamu" (bintang interaktif, guard guest).

### Perbaikan Backend (bug nyata, ditemukan saat uji)
- `MovieStatsService::getAverageRating` -> `round()` menerima string dari
  `avg()` SQLite -> **TypeError 500** saat film punya rating. Fix: cast ke
  `(float)` dulu (pola sama seperti `ratingMap()`).
- `MovieController::show` -> `additional()` **tidak** digabung oleh
  `JsonResource::resolve()` di Laravel 13 ini, sehingga `average_rating`,
  `review_count`, `in_watchlist`, dll. hilang dari respons. Fix: `array_merge`
  eksplisit.
- Diverifikasi: `GET /movies/{id}` kini `200` + mengembalikan `average_rating`,
  `review_count`, dan field per-user.
- Catatan: `backend/` adalah **git repo terpisah** (bukan submodule); commit di
  dalamnya (`de0987a`), parent mencatat gitlink.

---

## File Kunci (Arsitektur)

```
lib/
  main.dart                      # GoRouter tunggal + MyApp
  core/
    app_theme.dart               # warna + tema global (PERHATIAN: minimumSize infinity)
    api_client.dart              # Dio + interceptor token + baseUrl per-platform
    storage.dart                 # TokenStorage (key: 'auth_token')
  models/
    movie.dart, user.dart, review.dart
  providers/
    auth_provider.dart           # login/register/logout/checkSession
    movie_provider.dart          # moviesProvider, movieDetailProvider, movieReviewsProvider
    library_provider.dart        # watchlistProvider, watchedProvider
  repositories/
    movie_repository.dart
    watchlist_repository.dart
    watched_repository.dart
  pages/
    splash_page.dart             # -> /home
    home_page.dart               # grid katalog dari API + MainBottomNav(guest=1)
    login_page.dart              # guest navbar index 0
    register_page.dart           # halaman terpisah
    search_page.dart             # filter lokal dari moviesProvider
    watchlist_page.dart          # index 2 (login) / 0 (guest)
    profile_page.dart            # index 4 (login)
    movie_detail_page.dart       # tombol library via _LibraryActions
    review_form_page.dart        # MASIH SIMULASI (belum API)
  widgets/
    main_bottom_nav.dart         # guest 3 menu / login 5 menu
    home_tab_bar.dart, poster_tile.dart, movie_card.dart, rating_stars.dart
```

Indeks `MainBottomNav`:
- Guest: 0=Users(/login), 1=Films(/home), 2=Search(/search)
- Login: 0=Home, 1=Search, 2=Watchlist, 3=Log(belum ada), 4=Profile

---

## Endpoint Backend yang Sudah Dipakai

- `POST /login`, `POST /register` -> `{success, data:{user, token}}`
- `GET /me` -> `{success, data:{id,name,email,role,...}}`
- `POST /logout`
- `GET /movies`, `GET /movies/{id}`
- `GET/POST /watchlist`, `DELETE /watchlist/{movieId}`
- `GET/POST /watched`, `PATCH/DELETE /watched/{movieId}`

Belum dipakai (kandidat berikutnya):
- `GET/POST/PUT/DELETE /reviews` (sebagian: POST + GET sudah dipakai Tahap 4)
- `POST /movies/{id}/rate`, `DELETE /movies/{id}/rate`
- `GET /profile`, `/profile/stats`, `/profile/reviews`
- `GET /home`, `GET /feed`, `/diary`, `/lists`, `/favorites`, `/likes`, `/tags`, `/notifications`

---

## Validasi Terakhir

- `dart format lib test` -> rapi
- `flutter analyze` -> No issues found
- `flutter test` -> 3/3 passed (navigasi guest + validasi login)
- `flutter run -d chrome` -> 0 error/exception (backend Laravel hidup)
- Endpoint auth/watchlist/watched diuji langsung via HTTP -> sesuai
- Android -> **BELUM diuji** (tidak ada perangkat terdeteksi)

---

## Langkah Selanjutnya (TODO)

1. Merge Tahap 5 (rating di detail) + fix backend ke `main`.
2. Tampilkan daftar review di Detail Film — butuh endpoint publik review per film
   (backend belum punya; perlu `GET /movies/{id}/reviews` bila diinginkan).
3. Sambungkan `GET /home` bila ingin beranda khusus user login.
4. Rapikan `lib/pages/settings_page.dart` (belum punya rute, masih logout palsu).
5. Uji Android (verifikasi baseUrl `10.0.2.2`; HP fisik perlu IP LAN).
6. Sinkronkan `docs/PROGRESS.md` dengan struktur aktual.

> Catatan backend: `ReviewResource.user_name` hanya terisi bila relasi `user`
> di-eager-load. `ReviewController@index`/`store` belum memuatnya, jadi nama
> user tampil kosong (fallback `Anonymous` di app).
> `GET /movies/{id}` tidak mengembalikan rating milik user yang login, jadi
> bintang "Rating kamu" di app mulai dari 0 (tidak ter-preselect).

---

## Catatan / Jebakan

- Tema global `elevatedButtonTheme.minimumSize = Size(double.infinity, 50)`.
  Selalu set `minimumSize` eksplisit untuk tombol di dalam `Row`.
- Token disimpan di key `'auth_token'` (sama di `api_client.dart` & `storage.dart`).
- Guest tidak boleh memicu provider yang butuh token (watchlist/watched/profil) ->
  selalu cek `authProvider` dulu.
- Jangan jalankan `flutter pub get` tanpa perlu; dependency sudah ter-resolve.
