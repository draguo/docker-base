FROM php:8.2-cli-alpine

WORKDIR /var/www/html

ENV TZ=Asia/Shanghai


ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

## 安装基础环境
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk upgrade \
    && apk add bash \
    ca-certificates \
    openssl \
    && update-ca-certificates \
    ## Fix su execution (eg for tests)
    && mkdir -p /etc/pam.d/ \
    && echo 'auth sufficient pam_rootok.so' >> /etc/pam.d/su

RUN set -x \
    # Install services \
    && apk add \
    wget \
    curl \
    sed \
    tzdata \
    busybox-suid

RUN set -x \
    && apk add shadow \
    && apk add \
    # Install common tools
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
    # Install php environment
    && apk add \
    imagemagick \
    graphicsmagick \
    ghostscript \
    jpegoptim \
    pngcrush \
    optipng \
    pngquant \
    vips \
    rabbitmq-c \
    c-client \
    # Libraries
    libldap \
    icu-libs \
    libintl \
    libpq \
    libxslt \
    libzip \
    libmemcached \
    yaml \
    # Build dependencies
    autoconf \
    g++ \
    make \
    libtool \
    pcre-dev \
    gettext-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    vips-dev \
    krb5-dev \
    openssl-dev \
    imap-dev \
    imagemagick-dev \
    rabbitmq-c-dev \
    openldap-dev \
    icu-dev \
    postgresql-dev \
    libxml2-dev \
    ldb-dev \
    pcre-dev \
    libxslt-dev \
    libzip-dev \
    libmemcached-dev \
    # Install extensions
    && install-php-extensions \
    bcmath \
    bz2 \
    calendar \
    exif \
    ffi \
    intl \
    gettext \
    ldap \
    mysqli \
    imap \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    shmop \
    xsl \
    zip \
    gd \
    gettext \
    opcache \
    redis \
    imagick \
    igbinary \
    memcached \
    swoole \
    # Uninstall dev and header packages
    && apk del -f --purge \
    autoconf \
    g++ \
    make \
    libtool \
    pcre-dev \
    gettext-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    vips-dev \
    krb5-dev \
    openssl-dev \
    imap-dev \
    rabbitmq-c-dev \
    imagemagick-dev \
    openldap-dev \
    icu-dev \
    postgresql-dev \
    libxml2-dev \
    ldb-dev \
    pcre-dev \
    libxslt-dev \
    libzip-dev \
    libmemcached-dev

# 复制配置文件
COPY supervisord.*.conf /etc/supervisor/conf.d/
COPY php.ini ${PHP_INI_DIR}/conf.d/99-octane.ini
COPY start-container /usr/local/bin/start-container

# composer
RUN curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer

RUN chmod +x /usr/local/bin/start-container

EXPOSE 8000


ENTRYPOINT ["start-container"]

HEALTHCHECK --start-period=5s --interval=2s --timeout=5s --retries=8 CMD php artisan octane:status || exit 1