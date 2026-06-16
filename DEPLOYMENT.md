# Panduan Hosting Laravel (Hostinger)

## 1. Siapkan hosting
Untuk Hostinger, pastikan paket Anda mendukung:
- PHP 8.2+
- Composer
- MySQL
- Apache mod_rewrite

## 2. Upload project ke Hostinger
1. Zip seluruh isi project ini (tanpa folder vendor jika ukuran besar, lalu jalankan composer install di server).
2. Masuk ke Hostinger → File Manager.
3. Upload zip ke folder public_html.
4. Extract file tersebut.
5. Jika Anda ingin domain langsung mengarah ke aplikasi, pastikan folder yang dieksekusi adalah public_html.

## 3. Set document root
Jika hosting Anda memakai cPanel/DirectAdmin:
- Set document root ke folder public/

Jika tidak bisa, file .htaccess di root sudah diarahkan ke public/.

## 4. Buat database MySQL di Hostinger
1. Masuk ke Hostinger → MySQL Databases.
2. Buat database baru.
3. Buat user database dan beri akses ke database tersebut.
4. Isi kredensial ke file .env.

Contoh:
APP_ENV=production
APP_DEBUG=false
APP_URL=https://namadomainanda.com

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=nama_database
DB_USERNAME=nama_user
DB_PASSWORD=password_user

## 5. Jalankan perintah di server Hostinger
Masuk ke terminal/SSH Hostinger, lalu jalankan:
```bash
composer install --no-dev --optimize-autoloader
php artisan key:generate
php artisan migrate --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 6. Atur permission folder
```bash
chmod -R 775 storage bootstrap/cache
```

## 7. Jika Anda ingin hosting gratis
Pilihan paling realistis untuk demo/presentasi:
- InfinityFree
- 000webhost

Catatan penting:
- Hosting gratis biasanya terbatas, jadi Laravel bisa berjalan tetapi tidak seoptimal hosting berbayar.
- Jika provider tidak punya SSH/Composer, upload juga folder vendor dari project Anda.
- Pastikan provider mendukung PHP, MySQL, dan mod_rewrite.

Untuk hosting gratis, langkah paling aman:
1. Upload seluruh project ke public_html.
2. Pastikan folder public/ dipakai sebagai root aplikasi, atau biarkan file .htaccess yang sudah ada.
3. Isi .env dengan data MySQL gratis Anda.
4. Jalankan migrate dan storage:link di server jika SSH tersedia.
5. Jika tidak ada SSH, cukup upload vendor dan file yang sudah siap dari local project.

## 8. Tes akses
Buka domain Anda di browser.
