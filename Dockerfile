FROM php:7.3-apache-stretch

# install the PHP extensions we need
RUN apt-get update
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
        unzip
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-install exif gd intl opcache pcntl pdo_mysql zip
RUN pecl install imagick-3.4.4
RUN docker-php-ext-enable imagick

VOLUME /var/www/html

RUN a2enmod rewrite

ENV JINYA_VERSION 7.0.0

RUN curl -fsSL -o /var/www/html/jinya.zip "https://files.jinya.de/cms/stable/${JINYA_VERSION}.zip"

COPY vhost.conf /etc/apache2/sites-available/000-default.conf
COPY conf/memory-limit.ini /usr/local/etc/php/conf.d/memory-limit.ini
COPY conf/opcache.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
EXPOSE 80