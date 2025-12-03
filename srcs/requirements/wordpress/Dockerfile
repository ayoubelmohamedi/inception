FROM debian:bullseye

WORKDIR /var/www/html

# Install PHP-FPM and required PHP extensions from Debian repositories
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-mysqli \
    php7.4-gd \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-zip \
    php7.4-curl \
    curl \
    wget \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download WordPress
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf wordpress.tar.gz --strip-components=1 \
    && rm wordpress.tar.gz

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create log file for PHP errors
RUN touch /var/log/php_errors.log && chown www-data:www-data /var/log/php_errors.log

# Copy config files
COPY tools/docker-entrypoint.sh /usr/local/bin/
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/php.ini /etc/php/7.4/fpm/conf.d/99-custom.ini

# Set permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chown -R www-data:www-data /var/www/html

# Create directory for PHP-FPM
RUN mkdir -p /run/php

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm7.4", "-F"]


