FROM php:7.4-fpm-alpine3.15

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

WORKDIR /var/www/html

ENV TZ=Asia/Shanghai

RUN apk add --no-cache wget curl

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apk upgrade \
    && apk add --no-cache bash \
    ca-certificates \
    openssl \
    && update-ca-certificates \
    && mkdir -p /etc/pam.d/ \
    && echo 'auth sufficient pam_rootok.so' >> /etc/pam.d/su

RUN set -x \
    && apk add --no-cache \
    sed \
    tzdata \
    busybox-suid

RUN set -x \
    && apk add --no-cache shadow \
    && apk add --no-cache \
    zip \
    unzip \
    bzip2 \
    drill \
    ldns \
    openssh-client \
    rsync \
    patch \
    supervisor

RUN set -x \
    && apk add --no-cache \
    libjpeg-turbo \
    libpng \
    libwebp \
    freetype \
    libzip \
    icu-libs \
    libxslt \
    libmemcached-libs \
    yaml \
    rabbitmq-c \
    libldap \
    libpq

RUN set -x \
    && apk add --no-cache \
    jpegoptim \
    pngcrush \
    optipng \
    pngquant

RUN set -x \
    && apk add --no-cache \
    ghostscript

RUN set -x \
    && apk add --no-cache \
    vips

RUN set -x \
    && apk add --no-cache \
    imagemagick \
    imagemagick-libs

# 先更新包索引，然后单独安装 graphicsmagick
RUN set -x \
    && apk update \
    && apk add --no-cache graphicsmagick

RUN set -x \
    && apk add --no-cache c-client

RUN set -x \
    && install-php-extensions \
    bcmath \
    bz2 \
    soap \
    calendar \
    exif \
    intl \
    gettext \
    mysqli \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    sockets \
    zip

RUN set -x \
    && apk add --no-cache libzip-dev libldap-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/ \
    && install-php-extensions ldap

RUN set -x \
    && apk add --no-cache freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && install-php-extensions gd

RUN set -x \
    && install-php-extensions \
    sysvmsg \
    sysvsem \
    sysvshm \
    shmop

RUN set -x \
    && apk add --no-cache libxslt-dev \
    && install-php-extensions xsl

RUN set -x \
    && install-php-extensions \
    redis \
    igbinary \
    memcached

RUN set -x \
    && apk add --no-cache imap-dev \
    && docker-php-ext-configure imap --with-imap-ssl \
    && install-php-extensions imap

RUN set -x \
    && install-php-extensions ffi

RUN set -x \
    && install-php-extensions opcache

RUN set -x \
    && apk add --no-cache imagemagick-dev \
    && install-php-extensions imagick || echo "imagick extension installation skipped"

RUN docker-php-source delete \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer

COPY conf/ /opt/docker/
COPY conf/etc/php/php.ini ${PHP_INI_DIR}/conf.d/99-php.ini

CMD ["/usr/bin/supervisord","-c","/opt/docker/etc/supervisor.conf"]
