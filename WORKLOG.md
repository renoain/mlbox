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
- Status: Tahap 1–8 sudah di `main`; Tahap 9 (settings) selesai, belum di-commit
- Repo: mono-repo di `github.com/renoain/mlbox` (Flutter + backend Laravel), `main` up to date

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

### Tahap 6 — Halaman Log / Diary (API)
- `diary_repository.dart` (baru): `DiaryDay` + `DiaryEntry` + `getDiary()`
  -> `GET /diary` (dikelompokkan per tanggal).
- `library_provider.dart`: `diaryRepositoryProvider` + `diaryProvider`.
- `log_page.dart` (baru): daftar entri diary per tanggal (poster, judul,
  rating, catatan), state loading/error/empty + guard guest.
- `main.dart`: rute `/log` ditambahkan.
- `main_bottom_nav.dart`: menu **Log** (index 3) kini `go('/log')` — bukan lagi
  SnackBar "belum tersedia".
- Catatan: belum ada alur membuat diary dari UI (`POST /diary`), jadi halaman
  menampilkan empty state sampai alur "log film" dibuat.

### Tahap 7 — Alur Log Film (POST /diary)
- `diary_repository.dart`: `createDiary(movieId, watchedDate?, note?)` -> `POST /diary`.
- `movie_detail_page.dart`: tombol **LOG FILM** (full-width) membuka dialog
  (pilih tanggal via date picker + catatan opsional) -> `createDiary`, lalu
  invalidate `diaryProvider` + `watchlistProvider`.
- Alur terverifikasi: log film otomatis mengeluarkan film dari watchlist
  (backend `WatchlistService::remove`); duplikat tanggal sama -> 409 (error SnackBar).
- Kini halaman Log bisa terisi dari UI.

### Tahap 8 — Beranda Khusus User Login (GET /home)
- App: `home_repository.dart` (baru) -> `HomeData` (6 section: featured, latest,
  top_rated, most_watched, most_watchlisted, explore) + `getHome()`.
- `movie_provider.dart`: `homeRepositoryProvider` + `homeDataProvider`.
- `home_page.dart`: jika login -> tampilkan section horizontal dari `GET /home`;
  jika guest -> tetap `moviesProvider` (grid). Ada loading/error/empty.
- Backend fix: `HomeController::mapSection` memakai `additional()` yang tidak
  digabung `resolve()` -> `watched_count`/`watchlist_count` hilang. Fix:
  `array_merge` eksplisit (pola sama seperti `MovieController@show`).
- Terverifikasi: `GET /home` (auth) -> 200, 6 section, `watched_count` muncul.

### Tahap 9 — Rapikan Settings
- `settings_page.dart` -> `ConsumerWidget`; LOG OUT kini nyata
  (`authProvider.logout()` -> `/login`), tombol hanya tampil bila login.
- Item tanpa endpoint (Edit Profile, Change Password, Language, Theme, About,
  Help) -> SnackBar "Fitur belum tersedia." (tidak diam-diam mati).
- Rute `/settings` didaftarkan; ikon gear ditambahkan di `ProfilePage`
  (`push('/settings')`).
- Test baru: `Settings: placeholder item shows not-available message` (4/4 lolos).

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

## Sesi 2026-10-20 (lanjutan) — Poster, Data Film, dan Alur Tulis Review

### Yang sudah ada dari sesi sebelumnya (masih aktif)
- `lib/core/api_config.dart` — host adaptif: `10.0.2.2` (Android emulator),
  `127.0.0.1` (web/desktop), bisa di-override dengan
  `--dart-define=API_BASE_URL=http://<ip-lan>:8000`.
- `lib/widgets/poster_image.dart` — widget poster reusable: web pakai
  `Image.network` + `WebHtmlElementStrategy.fallback`, native pakai
  `CachedNetworkImage`, ada placeholder `Icons.movie_rounded` (bukan layar merah).
- `AndroidManifest.xml` — sudah ada `INTERNET` + `usesCleartextTraffic="true"`.
- `GET /api/media/{path}` (backend `MediaController`) — menyajikan poster lewat
  Laravel, **bukan** `/storage/...`, supaya responsnya membawa header CORS.
  Tanpa ini, Flutter Web memuat gambar via XHR dan browser memblokirnya.

### Bug yang ditemukan & diperbaiki di sesi ini

1. **Agregat rating hilang di film pertama tiap daftar** (root cause).
   `MovieResource` punya argumen constructor kedua `bool $withStats`. Laravel
   memetakan koleksi dengan `new MovieResource($model, $key)`, jadi argumen
   kedua berisi *kunci* koleksi (0, 1, 2, ...) yang di-coerce ke bool.
   Akibatnya film indeks 0 tidak dapat `average_rating`/`review_count`,
   sedangkan film lain dapat. Flag dipindah ke properti publik + factory
   `MovieResource::withStats()`.

2. **Daftar film tidak punya agregat sama sekali** (akibat langsung no. 1).
   `MovieController@index`, `HomeController`, dan `AdminMovieController@index`
   sekarang memakai `MovieStatsService::statsMap()` — satu query per tabel
   (bukan N+1) — lalu menyalin hasilnya ke tiap film.

3. **Alur "beri rating -> tulis review" gagal dengan 409.** `POST /movies/{id}/rate`
   membuat baris `reviews` (rating saja). Setelah itu `POST /reviews` menolak
   dengan 409 karena review-nya "sudah ada". `ReviewController@store` sekarang
   memakai `firstOrNew` (upsert): 201 untuk review baru, 200 untuk pembaruan.

4. **Cast/crew di Detail Film masih data dummy** ("Christian Bale / Patrick
   Bateman"). Sekarang dibaca dari API: `Movie` mem-parse `cast` (teks dipisah
   koma ATAU list), `crew`, `backdrop_url`, `original_title`, `language`,
   `country`, `is_featured`.

5. **Seeder membuat user dengan email kosong.** `env('DEMO_USER_EMAIL', 'default')`
   mengembalikan `''` kalau kuncinya ada di `.env` tapi nilainya kosong.
   Diganti `?:` + `updateOrCreate`. Akun demo sekarang:
   `demo@mailboxh.test` / `admin@mailboxh.test`, password `password`.

6. **Angka nol bawaan menimpa angka asli** di `MovieStatsService` — PHP `+`
   menyimpan nilai operand **kiri**, jadi `emptyStats() + [data asli]` membuang
   data. Diganti `array_merge` (operand kanan menang).

### Perbaikan tampilan
- `search_page.dart` menampilkan rating asli (`movie.averageRating`), bukan `0`.
- `poster_tile.dart` punya lencana bintang di pojok poster.
- `home_page.dart` memakai `AppTheme.background` (sebelumnya warna hardcode
  `#191C21` yang beda dari tema `#14181C`).
- `movie_detail_page.dart` memakai `backdrop_url` untuk header kalau ada.

---

## Sesi 2026-10-20 (kedua) — Fitur Log, Review, Tab Home, dan Profile

Urutan pengerjaan: **Task 1 -> Task 2 -> Task 4 -> Task 3**. Alasannya, Task 1
satu-satunya bug backend, dan Task 3 + Task 4 menampilkan data yang kosong
selama alur itu mati, jadi tidak bisa diverifikasi sebelum Task 1 beres.

### Task 1 — "Mark Watched" sekarang masuk ke Log

Akar masalahnya ada di backend, bukan di tombolnya: `POST /api/watched` hanya
membuat baris `watched`, sedangkan halaman Log membaca `GET /api/diary`
(tabel `diary_entries`). Jadi filmnya benar-benar tidak pernah masuk log.

- `App\Services\WatchLogService` (baru) — menjaga agar `watched` dan
  `diary_entries` selalu sinkron:
  - `markWatched()` — buat `watched` + entri log pada tanggal yang sama.
  - `unwatch()` — hapus `watched` + semua entri log film tersebut.
  - `deleteDiaryEntry()` — hapus entri log; `watched` ikut hilang kalau
    film itu tidak punya entri log lain.
- `WatchedController@store` dan `@destroy` memakai service tersebut.
- `DiaryController@store` sekarang juga menandai film sebagai watched.
  Log ulang di tanggal yang sama **memperbarui** entri, bukan 409.
- `LogController@store` memakai service yang sama dan `Review::firstOrNew`
  (sebelumnya `Review::create` → 500 kalau rating-nya sudah ada).
- Frontend: tombol "Watched" jadi hijau + ceklis saat aktif, abu-abu saat
  belum; `diaryProvider` di-invalidate supaya halaman Log ikut ter-update.

### Task 2 — Rating rata-rata + daftar review di Detail Film

- Backend: `GET /api/movies/{id}/reviews` (baru, **publik**) di
  `MovieController@reviews`, terdaftar di grup route `throttle:movies`.
- Backend: `user_name` sebelumnya kosong karena relasi `user` tidak pernah
  di-eager-load. Diperbaiki di `ReviewController@index`/`@store`,
  `ProfileController@reviews`, dan `MovieController@reviews`.
- Frontend: `_AverageRating` (bintang + rata-rata + jumlah review) di dekat
  judul, `_ReviewsSection` di bawah (avatar, nama, bintang, tanggal, teks).
- `Review` model sekarang membawa `movie` dan `likesCount`, dan `rating`
  aman terhadap null.

### Task 4 — Profile

- `GET /api/profile/stats` sudah ada di backend, tinggal dipakai.
- `ProfileStats` model, `ProfileRepository`, `profileStatsProvider`.
- UI: avatar dengan inisial, nama, email, grid 4 statistik (watched,
  watchlist, reviews, lists), pull-to-refresh, tombol Logout + Settings tetap.

### Task 3 — Tab Home: Reviews, Lists, Journal

- Tab **Reviews** -> `GET /api/reviews` (`myReviewsProvider`). Review punya
  poster, judul film, bintang, dan teksnya.
- Tab **Lists** -> `GET /api/lists`. Model `MovieList`, `ListRepository`,
  `listsProvider`. Kartu menampilkan judul, jumlah film, status publik/privat.
- Tab **Journal** -> placeholder "Editorial Journal coming soon".
- Guest melihat prompt "Masuk untuk melihat ..." di tab Reviews & Lists
  (keduanya butuh token), bukan crash atau layar kosong.

### File baru

| File | Isi |
|---|---|
| `backend/app/Services/WatchLogService.php` | sinkronisasi `watched` <-> `diary_entries` |
| `lib/models/movie_list.dart` | model kurasi |
| `lib/models/profile_stats.dart` | model statistik profil |
| `lib/repositories/list_repository.dart` | `GET /api/lists` |
| `lib/repositories/profile_repository.dart` | `GET /api/profile/stats` |
| `lib/providers/profile_provider.dart` | `profileStatsProvider` |

---

## Validasi Terakhir

- `dart format lib test` -> rapi
- `flutter analyze` -> No issues found
- `flutter test` -> 18/18 passed
- Uji integrasi HTTP end-to-end -> **73/73 passed** (4 skrip):
  - katalog/poster/auth/review -> 25/25
  - watched <-> log -> 14/14
  - endpoint review film -> 10/10
  - 4 fitur baru (log, review, tab, profil) -> 24/24
- `GET /api/movies/{id}/reviews` -> publik, `user_name` + `movie` terisi.
- `GET /api/profile/stats` -> watched/watchlist/reviews/lists/diary sesuai
  dengan isi tabel.
- Android -> **BELUM diuji** (tidak ada perangkat terdeteksi)

> Catatan: PowerShell 5.1 membaca file .ps1 tanpa BOM sebagai ANSI, jadi
> karakter non-ASCII di skrip uji bisa rusak (menghasilkan 422 palsu) dan
> literal ASCII pun bisa termutasi. Simpan skrip uji dengan BOM.

---

## Langkah Selanjutnya (TODO)

1. Merge kedua sesi ini ke `main` (semua perubahan masih uncommitted).
2. Sambungkan `GET /home` bila ingin beranda khusus user login.
3. Rapikan `lib/pages/settings_page.dart` (belum punya rute, masih logout palsu).
4. Uji Android (verifikasi baseUrl `10.0.2.2`; HP fisik perlu IP LAN).
5. Sinkronkan `docs/PROGRESS.md` dengan struktur aktual.
6. Section `featured` di `GET /home` kosong — `movies.json` tidak punya
   `is_featured: true`. Tandai 5 film lewat admin panel atau seeder.
7. Formulir "Tulis Review" belum memuat review yang sudah ada, jadi user
   tidak melihat teks lamanya sebelum menimpa.

> Catatan backend: `GET /movies/{id}` tidak mengembalikan rating milik user
> yang login, jadi bintang "Rating kamu" di app mulai dari 0 (tidak
> ter-preselect).

---

## Catatan / Jebakan

- **Jangan pakai argumen constructor kedua di `JsonResource`.** Laravel
  memanggil `new Resource($model, $key)` saat memetakan koleksi, jadi
  argumen kedua berisi kunci koleksi, bukan nilai pilihanmu.
- **Hati-hati operator `+` untuk array di PHP.** `+$` menyimpan nilai operand
  **kiri** untuk key yang sama. Pakai `array_merge` kalau nilai kanan yang
  harus menang.
- `env('KEY', 'default')` mengembalikan string kosong bila `KEY=` ada di
  `.env` tapi kosong. Pakai `env('KEY') ?: 'default'`.
- Tema global `elevatedButtonTheme.minimumSize = Size(double.infinity, 50)`.
  Selalu set `minimumSize` eksplisit untuk tombol di dalam `Row`.
- Token disimpan di key `'auth_token'` (sama di `api_client.dart` & `storage.dart`).
- Guest tidak boleh memicu provider yang butuh token (watchlist/watched/profil) ->
  selalu cek `authProvider` dulu.
- Jangan jalankan `flutter pub get` tanpa perlu; dependency sudah ter-resolve.
