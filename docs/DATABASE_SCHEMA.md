# MLBOX DATABASE SCHEMA

Skema database MySQL untuk MLBox versi MVP.
Sumber definisi skema adalah migration di server/database/migrations/.

## Prinsip

- Database: mlbox
- Nama tabel plural, snake_case
- Primary key: bigint auto increment
- Timestamp: created_at, updated_at (bawaan Laravel)
- Foreign key ke users: on delete cascade
- Role user: kolom users.role (enum user/admin)
- Rating dan review disimpan di tabel watched (bukan tabel reviews
  terpisah) untuk menyederhanakan MVP

## Entity Relationship

    users
      |
      +--> watchlist --> movies
      +--> watched -----> movies

Keterangan:

- users 1:N watchlist
- users 1:N watched
- movies 1:N watchlist
- movies 1:N watched
- Satu user hanya bisa punya 1 baris watchlist per film (unique)
- Satu user hanya bisa punya 1 baris watched per film (unique)

## Tabel

### 1. users

Bawaan Laravel + kolom role.

Migration: 0001_01_01_000000_create_users_table.php (bawaan) + add_role_to_users_table (baru)

| Kolom          | Tipe                 | Constraint               | Keterangan     |
| -------------- | -------------------- | ------------------------ | -------------- |
| id             | bigint               | PK, auto increment       |                |
| name           | varchar(255)         | not null                 |                |
| email          | varchar(255)         | unique, not null         |                |
| password       | varchar(255)         | not null                 | Hash bcrypt    |
| role           | enum('user','admin') | not null, default 'user' |                |
| remember_token | varchar(100)         | nullable                 | Bawaan Laravel |
| created_at     | timestamp            | nullable                 |                |
| updated_at     | timestamp            | nullable                 |                |

Catatan:

- Kolom role hanya bisa diubah lewat endpoint admin (di luar MVP,
  cukup lewat seeder)
- Form register tidak menerima input role

### 2. movies

Katalog film yang diinput admin.

Migration: create_movies_table

| Kolom      | Tipe         | Constraint         | Keterangan    |
| ---------- | ------------ | ------------------ | ------------- |
| id         | bigint       | PK, auto increment |               |
| title      | varchar(255) | not null           |               |
| synopsis   | text         | nullable           |               |
| poster_url | varchar(255) | nullable           | URL eksternal |
| year       | integer      | nullable           | Tahun rilis   |
| director   | varchar(255) | nullable           |               |
| actors     | text         | nullable           | Dipisah koma  |
| genre      | varchar(100) | nullable           |               |
| created_at | timestamp    | nullable           |               |
| updated_at | timestamp    | nullable           |               |

Index:

- title (untuk pencarian LIKE)

Catatan:

- Poster disimpan sebagai URL eksternal di MVP
- Upload file ditunda ke fase berikutnya

### 3. watchlist

Film yang ingin ditonton user.

Migration: create_watchlist_table

| Kolom      | Tipe      | Constraint         | Keterangan |
| ---------- | --------- | ------------------ | ---------- |
| id         | bigint    | PK, auto increment |            |
| user_id    | bigint    | FK users, cascade  |            |
| movie_id   | bigint    | FK movies, cascade |            |
| created_at | timestamp | nullable           |            |
| updated_at | timestamp | nullable           |            |

Unique: (user_id, movie_id)

### 4. watched

Film yang sudah ditonton user, termasuk rating dan review opsional.

Migration: create_watched_table

| Kolom      | Tipe      | Constraint              | Keterangan     |
| ---------- | --------- | ----------------------- | -------------- |
| id         | bigint    | PK, auto increment      |                |
| user_id    | bigint    | FK users, cascade       |                |
| movie_id   | bigint    | FK movies, cascade      |                |
| rating     | tinyint   | nullable, 1-5           | Bintang        |
| review     | text      | nullable                | Ulasan teks    |
| watched_at | date      | not null, default today | Tanggal tonton |
| created_at | timestamp | nullable                |                |
| updated_at | timestamp | nullable                |                |

Unique: (user_id, movie_id)

Catatan:

- rating nullable: boleh watched tanpa rating
- review nullable: boleh watched tanpa teks
- rating dan review disimpan di sini, tidak di tabel terpisah
- watched_at default hari ini jika tidak diisi

## Relasi Model (Laravel)

User:

- hasMany Watchlist
- hasMany Watched

Movie:

- hasMany Watchlist
- hasMany Watched

Watchlist:

- belongsTo User
- belongsTo Movie

Watched:

- belongsTo User
- belongsTo Movie

## Seed Data

AdminSeeder:

- 1 akun admin: admin@mlbox.test / password / role admin

MovieSeeder:

- 5-10 film contoh dengan judul, tahun, genre, sutradara, aktor,
  sinopsis, dan poster_url (URL eksternal)

## Tabel yang DITUNDA

Jangan dibuat di MVP:

- diary_entries (diary digabung ke watched)
- lists, list_items
- tags, diary_tags
- follows
- activities
- likes
- comments
- notifications
- favorites
- admin_audit_logs

Tabel-tabel di atas baru ditambahkan jika fitur terkait diaktifkan
kembali di PROJECT_OVERVIEW.md Bab 3.

## Migration Order

Urutan migration yang harus dibuat:

1. (bawaan) 0001_01_01_000000_create_users_table
2. (bawaan) 0001_01_01_000001_create_cache_table
3. (bawaan) 0001_01_01_000002_create_jobs_table
4. add_role_to_users_table
5. create_movies_table
6. create_watchlist_table
7. create_watched_table
8. (install:api) create_personal_access_tokens_table

Catatan:

- personal_access_tokens dibuat otomatis oleh php artisan install:api
- Jangan edit migration yang sudah Ran
- Perubahan skema selalu lewat migration baru
