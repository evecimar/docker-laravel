FROM php:7.4-fpm

ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions bcmath ctype json mbstring openssl pdo pdo_dblib pdo_mysql pdo_odbc pdo_pgsql pdo_sqlsrv xml phar dom \
    curl zip session xmlwriter simplexml fileinfo tokenizer

RUN apt-get update && apt-get install -y nginx git bash \
    && ln -s /usr/bin/php7 /usr/bin/php

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer \
    && rm -rf /var/www/* && mkdir /var/www/app

COPY files/php/phpinfo.php /var/www/app/index.php
COPY files/nginx/nginx.conf /etc/nginx/nginx.conf
COPY files/services.d /etc/services.d
COPY files/docker-entrypoint.sh //docker-entrypoint.sh

WORKDIR /var/www/app

ENTRYPOINT ["/docker-entrypoint.sh"]