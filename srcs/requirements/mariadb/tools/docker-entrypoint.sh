#!/bin/bash
set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting MariaDB initialization...${NC}"



# Initialize MariaDB data directory if not already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${YELLOW}Initializing MariaDB data directory...${NC}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    echo -e "${GREEN}MariaDB data directory initialized.${NC}"
fi

# Start MariaDB temporarily in the background to run initialization scripts
echo -e "${YELLOW}Starting temporary MariaDB instance...${NC}"
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

# Wait for MariaDB to be ready
echo -e "${YELLOW}Waiting for MariaDB to be ready...${NC}"
for i in {30..0}; do
    if mysqladmin ping --silent 2>/dev/null; then
        break
    fi
    echo -n "."
    sleep 1
done

if [ "$i" = 0 ]; then
    echo -e "${RED}MariaDB startup failed${NC}"
    exit 1
fi

echo -e "${GREEN}MariaDB is ready!${NC}"

# # Run initialization SQL script
# if [ -f "/tmp/init.sql" ]; then
#     echo -e "${YELLOW}Running initialization SQL script...${NC}"
#     mysql < /tmp/init.sql
#     echo -e "${GREEN}SQL script executed successfully.${NC}"
# fi

# Set root password if MYSQL_ROOT_PASSWORD is provided

echo  -e "MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD"

# 4. INTELLIGENT CHECK: Can we connect without a password?
# If yes, it's a fresh install (or from image). If no, it's already secured.
if mysql -u root -e "status" > /dev/null 2>&1; then
    echo -e "${YELLOW}Root user has no password. Running security setup...${NC}"

    # Create database and user
    if [ -n "$MYSQL_DATABASE" ] && [ -n "$WP_ADMIN_USER" ] && [ -n "$WP_ADMIN_PASSWORD" ]; then
        echo -e "${YELLOW}Creating database ${MYSQL_DATABASE} & user ${WP_ADMIN_USER}...${NC}"
        # Now we must use the password we just set to connect
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${WP_ADMIN_PASSWORD}';"
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${WP_ADMIN_USER}'@'%';"
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
        echo -e "${GREEN}Database and user created.${NC}"
    fi
else
    echo -e "${GREEN}Root password already set. Skipping initialization.${NC}"
fi

# Stop the temporary MariaDB instance
echo -e "${YELLOW}Stopping temporary MariaDB instance...${NC}"
if ! kill -s TERM "$pid" || ! wait "$pid"; then
    echo -e "${RED}MariaDB shutdown failed${NC}"
    exit 1
fi

echo -e "${GREEN}MariaDB initialization complete!${NC}"

# Start MariaDB in foreground mode
echo -e "${GREEN}Starting MariaDB server...${NC}"
exec mysqld --user=mysql --console
