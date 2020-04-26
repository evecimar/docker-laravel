#!/bin/bash
set -e

git=$git_url
nginx=$nginx_conf_url
command=$custom_command_url
project_dir="/var/www/app"

cd /var/www/app/
if [ ! -z $git ]
then
    cd /var/www/app/
    rm -R *
    if [ -z $git_branch ]
        then
        git_branch=master
    fi
    git clone -b $git_branch $git_url

    repo_url=$git_url
    repo=${repo_url##*/}
    project_dir=/var/www/app/${repo%%.git*}
    mv $project_dir/* /var/www/app/
    
fi

file="docker/nginx.conf"
if [ -f "$file" ]
then
    mv docker/nginx.conf /etc/nginx/nginx.conf
fi

file="docker/custom_command.sh"
if [ -f "$file" ]
then
    mv docker/custom_command.sh /custom_command.sh
    chmod +x /custom_command.sh
    /custom_command.sh
fi

if [ ! -z $nginx ]
then
    rm /nginx.conf
    wget -O /nginx.conf $nginx_conf_url
    mv /nginx.conf /etc/nginx/nginx.conf
fi

if [ ! -z $command ]
then
    rm /start.sh
    wget -O /start.sh $custom_command_url
    chmod +x /start.sh
    /start.sh
fi

# For Newrelic's APM (Application Monitoring) license and appname are required.
# Enviroment variables `NEW_RELIC_LICENSE_KEY` and `NEW_RELIC_APP_NAME` are required when buidling Docker image,
# so you must set them in your **BuildConfig** Environments.
if [ "$APP_STAGE" != "dev" ]
then
    sed -i \
        -e "s/newrelic.license =.*/newrelic.license = ${NEW_RELIC_LICENSE_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = ${NEW_RELIC_APP_NAME}/" \
        /usr/local/etc/php/conf.d/newrelic.ini
fi 

#/bin/s6-svscan
#/etc/services.d

nginx
php-fpm
