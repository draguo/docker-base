FROM draguo/php:7-fpm

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