FROM php:8.5-fpm-alpine AS builder

RUN apk add --no-cache \
    build-base \
    libzip-dev \
    zlib-dev \
    autoconf \
    && docker-php-ext-install \
        pdo_mysql \
        zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del autoconf build-base


FROM php:8.5-fpm-alpine AS base

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

RUN apk add --no-cache \
    git \
    unzip \
    supervisor \
    libzip \
    nano

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY docker/php/supervisord.conf /etc/supervisor/conf.d/workers.conf

WORKDIR /var/www/app


FROM base AS prod

COPY . .
RUN composer install --no-dev --optimize-autoloader


FROM base