# MLBox

Aplikasi **diary film sosial** + katalog film untuk desktop web (Chrome) dan
Android. Dibangun sebagai **kloning Letterboxd**: users bisa menemukan film,
menyimpan ke watchlist, mencatat film yang sudah ditonton beserta rating dan
review, membuat list, mengikuti pengguna lain, dan melihat activity feed.

| | |
|---|---|
| **Aplikasi asli** | Letterboxd (letterboxd.com) |
| **Nama plesetan / clone** | **MLBox** (nama paket: `mlbox`) |
| **Stack** | Flutter (frontend) + Laravel Sanctum (REST API) + MySQL |
| **Platform** | Flutter Web / Windows desktop (Chrome), Android |

---

## Daftar Anggota Kelompok

| No. | Nama | NIM |
|---|---|---|
| 1 | Revalina Cheterine Syalomita Renmaur | 24051214235 |
| 2 | Lindra pramono | 24051214240 |
| 3 | Fernando Kinansyah | 24051214214 |
| 4 | Reno Alfaridzi Ilham Nugroho | 24051214221 |

---

## Struktur Proyek

```
mlbox/
├── lib/            # Aplikasi Flutter (frontend)
│   ├── core/       # router, tema, api client, storage
│   ├── models/     # model data (movie, user, review, ...)
│   ├── pages/      # halaman (home, search, movie detail, profile, ...)
│   ├── providers/  # state management (Riverpod)
│   ├── repositories/# lapisan akses API
│   └── widgets/    # komponen reusable
├── backend/        # REST API Laravel (Sanctum)
│   ├── app/Http/Controllers/Api/
│   ├── database/migrations & seeders
│   └── routes/api.php
├── docs/           # PROJECT_OVERVIEW, DATABASE_SCHEMA, PROGRESS
└── test/           # unit & widget test Flutter
```

---

## Fitur Utama

- Katalog film: jelajahi, cari, filter genre, detail film (sinopsis, sutradara,
  aktor, rating rata-rata, poster).
- Watchlist: simpan / hapus film yang ingin ditonton.
- Watched + rating bintang + review teks.
- Lists kurasi, likes, diary & tags.
- Profil: statistik, film favorit, review, list, dan profil publik pengguna lain.
- Sosial: follow, followers/following, activity feed, notifikasi, komentar review.
- Admin: kelola film, genre, user, review, list, tag, dan audit log.
- Tamu (guest) bisa menjelajahi katalog; aksi tulis meminta login.

---

## Tech Stack

**Frontend (Flutter)**

| Paket | Kegunaan |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Routing + redirect auth |
| `dio` | HTTP client + interceptor token |
| `flutter_secure_storage` | Penyimpanan token login |
| `shared_preferences` | Preferensi pengguna (mis. bahasa) |
| `cached_network_image` | Cache poster film |

**Backend (Laravel)**

- REST API dengan token `Laravel Sanctum` (Bearer token)
- Otorisasi admin lewat middleware `role:admin`
- Validasi memakai `FormRequest`
- Rate limiting per endpoint (`throttle:movies`, `throttle:api`, dll.)

**Database:** MySQL, tabel `mailboxh`, definisi skema pada `backend/database/migrations`.

---

## Panduan Menjalankan Proyek

### Prasyarat

| Tool | Versi |
|---|---|
| Flutter SDK | 3.47+ (Dart 3.13+) |
| PHP | 8.2+ (terpasang: 8.3) |
| Composer | 2.x |
| MySQL | 8.x (database `mailboxh`) |

### 1. Jalankan Backend (Laravel)

```bash
cd backend

# 1) Install dependency
composer install

# 2) Siapkan konfigurasi (skip kalau .env sudah ada)
cp .env.example .env        # Windows: copy .env.example .env
php artisan key:generate

# 3) Atur koneksi database di backend/.env
#    DB_CONNECTION=mysql
#    DB_DATABASE=mailboxh
#    DB_USERNAME=root
#    DB_PASSWORD=
#    Opsional untuk akun demo:
#    DEMO_ADMIN_EMAIL=admin@mailboxh.test
#    DEMO_USER_EMAIL=demo@mailboxh.test
#    DEMO_USER_PASSWORD=password

# 4) Buat tabel + isi data contoh (film, genre, user demo)
php artisan migrate --seed

# 5) Link storage supaya poster bisa diakses
php artisan storage:link

# 6) Jalankan server
php artisan serve
```

Backend sekarang berjalan di `http://127.0.0.1:8000`, API di
`http://127.0.0.1:8000/api`.

> **Akun demo bawaan seeder:** `demo@mailboxh.test` (user) dan
> `admin@mailboxh.test` (admin), password `password` — kecuali
> `DEMO_USER_PASSWORD` diisi di `.env`.

### 2. Jalankan Frontend (Flutter)

```bash
# Dari folder root proyek
flutter pub get

# Web / desktop (Chrome)
flutter run -d chrome

# Windows desktop
flutter run -d windows

# Android emulator
flutter run -d android
```

Alamat backend dipilih otomatis (`lib/core/api_config.dart`):

| Target | Base URL |
|---|---|
| Web / Windows / iOS | `http://127.0.0.1:8000/api` |
| Android emulator | `http://10.0.2.2:8000/api` |
| HP Android (Wi-Fi) | `flutter run --dart-define=API_BASE_URL=http://<IP-LAN>:8000` |

### 3. Menjalankan Test

```bash
flutter test              # test Flutter (unit + widget)
cd backend && php artisan test   # test backend Laravel
```

---

## Catatan Teknis

- Base URL API bisa dioverride saat run:
  `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000`
- Token disimpan di `flutter_secure_storage` dengan key `auth_token`;
  interceptor Dio menambah header `Authorization: Bearer <token>` otomatis.
- Respons 401 menghapus token lokal dan memaksa user login ulang.
- Tema gelap ala Letterboxd: background `#14181C`, surface `#1C252E`,
  primary `#00E054`.
- Dokumentasi lengkap ada di `docs/`:
  - `docs/PROJECT_OVERVIEW.md` — tujuan, fitur, arsitektur, kontrak API
  - `docs/DATABASE_SCHEMA.md` — skema database
  - `docs/PROGRESS.md` — progres pengerjaan
  - `WORKLOG.md` — catatan kerja per sesi
