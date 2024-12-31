ARG PHP_VERSION=8.2
ARG FRANKENPHP_VERSION=1.3.6
ARG COMPOSER_VERSION=2.8

FROM composer:${COMPOSER_VERSION} AS vendor

FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION} AS base

ARG TZ=Asia/Shanghai
ARG APP_DIR=/var/www/html

WORKDIR ${APP_DIR}

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

RUN apt-get update; \
    apt-get upgrade -yqq; \
    apt-get install -yqq --no-install-recommends \
    apt-utils \
    bash \
    curl \
    wget \
    ca-certificates \
    supervisor \
    zip \
    unzip \
    bzip2 \
    libzip-dev \
    libsodium-dev \
    libbrotli-dev \
    # Install PHP extensions (included with dunglas/frankenphp)
    && install-php-extensions \
    bz2 \
    pcntl \
    mbstring \
    bcmath \
    sockets \
    pgsql \
    pdo_pgsql \
    opcache \
    exif \
    pdo_mysql \
    zip \
    intl \
    gd \
    redis \
    memcached \
    igbinary \
    ldap \
    && apt-get -y autoremove \
    && apt-get clean \
    && docker-php-source delete \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm /var/log/lastlog /var/log/faillog

COPY supervisord.*.conf /etc/supervisor/conf.d/
COPY php.ini ${PHP_INI_DIR}/conf.d/99-octane.ini
COPY start-container /usr/local/bin/start-container

COPY --link --from=vendor /usr/bin/composer /usr/bin/composer

RUN chmod +x /usr/local/bin/start-container

EXPOSE 8000

ENTRYPOINT ["start-container"]

HEALTHCHECK --start-period=5s --interval=2s --timeout=5s --retries=8 CMD php artisan octane:status || exit 1
