#!/usr/bin/env bash
unzip /var/www/html/jinya.zip -d /var/www/html
chown www-data:www-data /var/www/html
exec "$@"