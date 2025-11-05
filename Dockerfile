FROM draguo/php:7-fpm

# nginx
RUN set -x \
    # Install nginx
    && apk add \
    nginx

# 配置文件
COPY conf/ /opt/docker/
COPY conf/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/etc/php/php.ini ${PHP_INI_DIR}/conf.d/99-php.ini

EXPOSE 80 443

CMD ["/usr/bin/supervisord","-c","/opt/docker/etc/supervisor.conf"]
