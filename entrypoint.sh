#!/usr/bin/env bash
unzip /var/www/jinya.zip -d /var/www/html
cp /.htaccess /var/www/html/public/.htaccess
chown www-data:www-data /var/www/html
exec "$@"