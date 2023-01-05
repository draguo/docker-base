FROM php:7.4.27-fpm-alpine

WORKDIR /var/www/html

ENV TZ=Asia/Shanghai

COPY conf/ /opt/docker/
COPY conf/etc/nginx/nginx.conf /etc/nginx/nginx.conf

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
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
        supervisor\
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
        patch


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
        yaml-dev \
    # Install extensions
    && PKG_CONFIG_PATH=/usr/local docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp \
    && docker-php-ext-configure ldap \
    && PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install \
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
        soap \
        sockets \
        tokenizer \
        sysvmsg \
        sysvsem \
        sysvshm \
        shmop \
        xmlrpc \
        xsl \
        zip \
        gd \
        gettext \
        opcache \
    && pecl install apcu \
    && printf "\n" | pecl install vips \
    && pecl install redis \
    && pecl install imagick \
    && pecl install amqp \
    && pecl install yaml \
    && pecl install igbinary\
    && pecl install memcached-3.2.0\
    && docker-php-ext-enable \
        apcu \
        redis \
        imagick \
        amqp \
        vips \
        igbinary \
        memcached \
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
        libmemcached-dev \
        yaml-dev \
    && curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer

# nginx
RUN set -x \
    # Install nginx
    && apk add \
        nginx


# python
RUN apk add python3 py3-pip \
    && pip install requests serial pyserial pymysql

EXPOSE 80 443

CMD ["/usr/bin/supervisord","-c","/opt/docker/etc/supervisor.conf"]