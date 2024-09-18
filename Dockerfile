FROM php:7.4-fpm-alpine

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
    # Install extensions
    && install-php-extensions \
    bcmath \
    bz2 \
    soap \
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
    && docker-php-source delete \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# composer
RUN curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer

# nginx
RUN set -x \
    # Install nginx
    && apk add \
    nginx

# python
RUN set -x \
    # Install python
    && apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo pkgconfig \
    && apk add python3 py3-pip \
    && pip install requests pyserial pymysql cryptography \
    && apk del gcc musl-dev python3-dev libffi-dev openssl-dev cargo pkgconfig

# 配置文件
COPY conf/ /opt/docker/
COPY conf/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/etc/php/php.ini ${PHP_INI_DIR}/conf.d/99-php.ini

EXPOSE 80 443

CMD ["/usr/bin/supervisord","-c","/opt/docker/etc/supervisor.conf"]