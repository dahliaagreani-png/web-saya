FROM php:8.2-apache

# 1. Install ekstensi sistem yang dibutuhkan oleh Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# 2. Aktifkan mod_rewrite untuk Apache (Wajib untuk routing Laravel)
RUN a2enmod rewrite

# 3. Ubah Document Root Apache agar langsung mengarah ke folder public Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 4. Tentukan folder kerja utama di dalam server kontainer
WORKDIR /var/www/html

# 5. Salin seluruh kode proyek Laravel Anda dari GitHub ke dalam server kontainer
COPY . .

# 6. Ambil biner resmi Composer (Solusi aman & anti-gagal untuk RAM gratisan)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 7. Jalankan instalasi dependensi vendor Laravel tanpa memuat paket development
RUN composer install --no-dev --optimize-autoloader

# 8. Atur izin akses (permission) folder utama agar Laravel tidak eror 500
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Buka jalur komunikasi port internet
EXPOSE 80
