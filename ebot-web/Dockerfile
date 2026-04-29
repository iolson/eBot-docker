# Stage 1: Build frontend assets
FROM node:22-alpine AS node-builder
RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/iolson/eBot-CS2-Web.git .
RUN npm ci && npm run build

# Stage 2: PHP-FPM application
FROM php:8.4-fpm

RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    libxml2-dev libzip-dev zip unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip sockets \
    && pecl install redis && docker-php-ext-enable redis \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "upload_max_filesize=40M\npost_max_size=40M\nmemory_limit=256M\ndate.timezone=UTC" \
    > /usr/local/etc/php/conf.d/ebot.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

RUN git clone https://github.com/iolson/eBot-CS2-Web.git .

RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist \
    && composer dump-autoload --optimize

COPY --from=node-builder /app/public/build public/build

RUN chown -R www-data:www-data storage bootstrap/cache

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 9000
CMD ["/setup.sh"]
