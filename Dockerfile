FROM composer:2.10.2@sha256:5946476338742b200bb9ff88f8be56275ddae4b3949c72305cb0dbf10cfcb760 AS composer

FROM node:24.18.0-alpine3.23@sha256:595398b0081eacda8e1c4c5b97b76cd1020e4d58a8ebcb4843b9bca1e79e7436 AS frontend
WORKDIR /build
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts
COPY resources ./resources
COPY vite.config.js tsconfig.json ./
RUN npm run build

FROM php:8.4.23-fpm-alpine3.23@sha256:6c0a1d52c7c1f01d61c6a0821eb326dbb3c318bfa60b7909d4b2ce0a41b94c2b AS runtime

ARG APP_UID=10001
ARG APP_GID=10001

RUN set -eux; \
    apk add --no-cache \
        fcgi \
        freetype \
        icu-libs \
        libcurl \
        libjpeg-turbo \
        libxml2 \
        libpng \
        libpq \
        libzip \
        oniguruma \
        su-exec; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        freetype-dev \
        icu-dev \
        curl-dev \
        libjpeg-turbo-dev \
        libxml2-dev \
        libpng-dev \
        libzip-dev \
        linux-headers \
        oniguruma-dev \
        postgresql-dev; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" bcmath curl dom gd intl mbstring opcache pcntl pdo_pgsql sockets xml zip; \
    pecl install redis-6.3.0; \
    docker-php-ext-enable redis; \
    apk del .build-deps; \
    addgroup -g "$APP_GID" -S arzzaq; \
    adduser -u "$APP_UID" -S -D -H -G arzzaq arzzaq

COPY --from=composer /usr/bin/composer /usr/local/bin/composer
WORKDIR /srv/app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-progress \
    --no-scripts \
    --no-autoloader \
    --prefer-dist

COPY . .
COPY --from=frontend /build/public/build ./public/build
COPY docker/app/php.ini /usr/local/etc/php/conf.d/99-arzzaq.ini
COPY docker/app/php-fpm.conf /usr/local/etc/php-fpm.d/zz-arzzaq.conf
COPY docker/app/entrypoint.sh /usr/local/bin/arzzaq-entrypoint

ENV APP_ENV=build \
    APP_DEBUG=false \
    COMPOSER_ALLOW_SUPERUSER=1

RUN set -eux; \
    composer dump-autoload --classmap-authoritative --no-dev --no-interaction; \
    php artisan package:discover --ansi; \
    chmod 0555 /usr/local/bin/arzzaq-entrypoint; \
    chown -R arzzaq:arzzaq storage bootstrap/cache; \
    find storage bootstrap/cache -type d -exec chmod 0770 {} +; \
    find storage bootstrap/cache -type f -exec chmod 0660 {} +

ENV APP_ENV=production
USER arzzaq:arzzaq
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/arzzaq-entrypoint"]
CMD ["php-fpm", "--nodaemonize"]

HEALTHCHECK --interval=10s --timeout=3s --start-period=20s --retries=5 \
    CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 | grep -q pong || exit 1
