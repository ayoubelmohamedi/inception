#!/bin/bash
set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting MariaDB initialization...${NC}"



#  init maria if not exist 
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${YELLOW}Initializing MariaDB data directory...${NC}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    echo -e "${GREEN}MariaDB data directory initialized.${NC}"
fi

# run in background a temporary mariadb instance
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


if mysql -u root -e "status" > /dev/null 2>&1; then
    echo -e "${YELLOW}Root user has no password. Running security setup...${NC}"

    # Create database and user
    if [ -n "$MYSQL_DATABASE" ] && [ -n "$WP_ADMIN_USER" ] && [ -n "$WP_ADMIN_PASSWORD" ]; then
        echo -e "${YELLOW}Creating database ${MYSQL_DATABASE} & user ${WP_ADMIN_USER}...${NC}"
        
        mysql -u root  -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
        mysql -u root  -e "CREATE USER IF NOT EXISTS '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${WP_ADMIN_PASSWORD}';"
        mysql -u root  -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${WP_ADMIN_USER}'@'%';"
        mysql -u root  -e "FLUSH PRIVILEGES;"
        echo -e "${GREEN}Database and user created.${NC}"
    fi
else
    echo -e "${GREEN}Root password already set. Skipping initialization.${NC}"
fi

echo -e "${YELLOW}Stopping temporary MariaDB instance...${NC}"
if ! kill -s TERM "$pid" || ! wait "$pid"; then
    echo -e "${RED}MariaDB shutdown failed${NC}"
    exit 1
fi

echo -e "${GREEN}MariaDB initialization complete!${NC}"

echo -e "${GREEN}Starting MariaDB server...${NC}"
exec mysqld --user=mysql --console
