# Database Mailboxh

Panduan cepat setup database MySQL untuk backend Laravel.

## Prasyarat

- Laragon 6 dengan MySQL aktif.
- Composer terinstal.
- PHP 8.2 ke atas.
- VSCode.

## Langkah Cepat

Jalankan dari folder `backend/`:

```
cp .env.example .env
composer install
php artisan key:generate
```

Buat database (pilih salah satu):

```
mysql -u root -e "SOURCE database/create_database.sql;"
```

atau buka HeidiSQL lalu jalankan isi `database/create_database.sql`.

Lanjut migrasi dan seed:

```
php artisan migrate
php artisan db:seed
php artisan storage:link
php artisan serve
```

## Cek Status

```
php artisan migrate:status
```

Semua baris harus berstatus `Ran`.

## Reset

```
php artisan migrate:fresh --seed
```

Perintah ini menghapus seluruh tabel lalu membuat ulang beserta data contoh.

## Troubleshooting

- `Unknown database 'mailboxh'`: database belum dibuat. Jalankan `create_database.sql` dulu.
- `Access denied for user 'root'`: cek `DB_USERNAME` dan `DB_PASSWORD` di `.env`. Laragon bawaan memakai user `root` tanpa password.
- `Connection refused`: MySQL belum jalan. Buka Laragon lalu tekan Start All dan pastikan layanan MySQL berwarna hijau.
- `php tidak dikenali`: PATH PHP Laragon belum terdaftar. Tambahkan `C:\laragon\bin\php\php-8.x\bin` ke PATH atau jalankan dari Terminal Laragon.
