FROM php:7.3-apache-stretch

# install the PHP extensions we need
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libevent-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
        libmagickwand-dev \
        libzip-dev \
        imagemagick \
        unzip
RUN pecl channel-update pecl.php.net
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-install exif gd intl opcache pcntl pdo_mysql zip curl
RUN pecl install imagick-3.4.3
RUN docker-php-ext-enable imagick

VOLUME /var/www/html

RUN a2enmod rewrite
ENV VERSION=9.1.1

COPY vhost.conf /etc/apache2/sites-available/000-default.conf
COPY conf/memory-limit.ini /usr/local/etc/php/conf.d/memory-limit.ini
COPY conf/opcache.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
COPY entrypoint.sh /entrypoint.sh
COPY .htaccess /.htaccess
COPY installer/ /installer/

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
EXPOSE 80