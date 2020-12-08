FROM php:7.4-fpm

ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions bcmath ctype json mbstring openssl pdo pdo_dblib pdo_mysql pdo_odbc pdo_pgsql pdo_sqlsrv xml phar dom \
    curl zip session xmlwriter simplexml fileinfo tokenizer intl redis

RUN apt-get update && apt-get install -y nginx git bash wget supervisor \
    && ln -s /usr/bin/php7 /usr/bin/php

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer \
    && rm -rf /var/www/* && mkdir /var/www/app

RUN mkdir -p /var/log/newrelic /var/run/newrelic && \
    touch /var/log/newrelic/php_agent.log /var/log/newrelic/newrelic-daemon.log && \
    chmod -R g+ws /tmp /var/log/newrelic/ /var/run/newrelic/ && \
    chown -R 1001:0 /tmp /var/log/newrelic/ /var/run/newrelic/

# Download and install Newrelic binary
RUN export NEWRELIC_VERSION=$(curl -sS https://download.newrelic.com/php_agent/release/ | sed -n 's/.*>\(.*linux\).tar.gz<.*/\1/p') && \
  curl -L "https://download.newrelic.com/php_agent/release/${NEWRELIC_VERSION}.tar.gz" | tar -C /tmp -zx && \
  export NR_INSTALL_USE_CP_NOT_LN=1 && \
  export NR_INSTALL_SILENT=1 && \
  /tmp/newrelic-php5-*/newrelic-install install && \
  rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \
  sed -i \
      -e 's/;newrelic.daemon.app_connect_timeout =.*/newrelic.daemon.app_connect_timeout=15s/' \
      -e 's/;newrelic.daemon.start_timeout =.*/newrelic.daemon.start_timeout=5s/' \
      /usr/local/etc/php/conf.d/newrelic.ini

COPY files/php/phpinfo.php /var/www/app/index.php
COPY files/nginx/nginx.conf /etc/nginx/nginx.conf
COPY files/services.d /etc/services.d
COPY files/docker-entrypoint.sh /docker-entrypoint.sh
COPY files/supervisor/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

WORKDIR /var/www/app

ENTRYPOINT ["/docker-entrypoint.sh"]