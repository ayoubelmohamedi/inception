#!/bin/bash
set -eu

echo "Starting WordPress setup..."

# 1. Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
until mysqladmin ping -h "$WORDPRESS_DB_HOST" --silent; do
    echo -n "."
    sleep 2
done
echo "MariaDB is ready!"

# 2. Check if WordPress is already configured
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    
    # Create wp-config.php using WP-CLI
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --path=/var/www/html \
        --allow-root

    echo "wp-config.php created."
fi

# 3. Install WordPress if not already installed
if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="admin@$DOMAIN_NAME" \
        --skip-email \
        --path=/var/www/html \
        --allow-root

    echo "WordPress installed."

    # 4. Create a second user (editor role)
    if [ -n "$WP_USER" ] && [ -n "$WP_USER_PASSWORD" ]; then
        echo "Creating additional user..."
        wp user create "$WP_USER" "editor@$DOMAIN_NAME" \
            --user_pass="$WP_USER_PASSWORD" \
            --role=editor \
            --path=/var/www/html \
            --allow-root 2>/dev/null
        echo "User $WP_USER created."
    fi
else
    echo "WordPress is already installed."
fi

# Fix permissions
chown -R www-data:www-data /var/www/html

echo "WordPress setup complete!"

# Execute the CMD from Dockerfile (php-fpm)
exec "$@"