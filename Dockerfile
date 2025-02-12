ARG PHP_VERSION=8.2
ARG COMPOSER_VERSION=2.8

FROM composer:${COMPOSER_VERSION} AS vendor

FROM php:${PHP_VERSION}-fpm AS base

ARG TZ=Asia/Shanghai
ARG APP_DIR=/var/www/html

WORKDIR ${APP_DIR}

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

# 添加 PHP 扩展安装工具并设置权限
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

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


RUN arch="$(uname -m)" \
    && case "$arch" in \
    armhf) _cronic_fname='supercronic-linux-arm' ;; \
    aarch64) _cronic_fname='supercronic-linux-arm64' ;; \
    x86_64) _cronic_fname='supercronic-linux-amd64' ;; \
    x86) _cronic_fname='supercronic-linux-386' ;; \
    *) echo >&2 "error: unsupported architecture: $arch"; exit 1 ;; \
    esac \
    && wget -q "https://github.com/aptible/supercronic/releases/download/v0.2.33/${_cronic_fname}" \
    -O /usr/bin/supercronic \
    && chmod +x /usr/bin/supercronic \
    && mkdir -p /etc/supercronic

# nginx
RUN set -x \
    # Install nginx
    && apk add \
    nginx

# 复制配置文件
COPY supervisord.*.conf /etc/supervisor/conf.d/
COPY php.ini ${PHP_INI_DIR}/conf.d/99-octane.ini
COPY start-container /usr/local/bin/start-container

COPY --link --from=vendor /usr/bin/composer /usr/bin/composer

# 设置可执行权限
RUN chmod +x /usr/local/bin/start-container

EXPOSE 80 443

# 设置入口点
ENTRYPOINT ["start-container"]