FROM alpine:3.10

ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

RUN apk --update add ca-certificates

RUN echo "https://dl.bintray.com/php-alpine/v3.9/php-7.4" >> /etc/apk/repositories

RUN apk add --update nginx git bash php-fpm php-bcmath php-ctype php-json php-mbstring php-openssl php-pdo php-xml php-phar \
    && php-dom php-curl php-common php-json php-mysql php-xml php-zip && \
    && ln -s /usr/bin/php7 /usr/bin/php

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer \
    && rm -rf /var/www/* && mkdir /var/www/app

COPY files/php/conf.d/local.ini /etc/php7/conf.d/
COPY files/php/php-fpm.conf /etc/php7/
COPY files/php/phpinfo.php /var/www/app/index.php
COPY files/nginx/nginx.conf /etc/nginx/nginx.conf
COPY files/services.d /etc/services.d
COPY files/docker-entrypoint.sh //docker-entrypoint.sh

WORKDIR /var/www/app

ENTRYPOINT ["/docker-entrypoint.sh"]