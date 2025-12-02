#!/bin/bash

# Check if wp-config.php exists
if [ ! -f /var/www/html/wp-config.php ]; then
    # Copy the sample config
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    # Update the config with env vars (using sed)
    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/html/wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/html/wp-config.php
fi

# Execute the CMD from Dockerfile (php-fpm)
exec "$@"