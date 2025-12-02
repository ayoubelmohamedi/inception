#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}AYOUUUUB${NC}"
echo -e "${GREEN}Starting MariaDB initialization...${NC}"

# TODO delete 

first_run=false

# Initialize MariaDB data directory if not already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo -e "${YELLOW}Initializing MariaDB data directory...${NC}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    echo -e "${GREEN}MariaDB data directory initialized.${NC}"
    first_run=true
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

# Run initialization SQL script
if [ -f "/tmp/init.sql" ]; then
    echo -e "${YELLOW}Running initialization SQL script...${NC}"
    mysql < /tmp/init.sql
    echo -e "${GREEN}SQL script executed successfully.${NC}"
fi

echo "helloo here AYOUB"
# Set root password if MYSQL_ROOT_PASSWORD is provided
if [ "$first_run" = true ] && [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    echo -e "${YELLOW}Setting root password...${NC}"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"
    echo -e "${GREEN}Root password set.${NC}"
fi

if [ "$first_run" = true ]; then
    echo -e "${GREEN} FIRST RUN: ABOUT TO CHANGE USER CONTENT${NC}"
fi

# Create additional users if specified
if [ "$first_run" = true ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ] && [ -n "$MYSQL_DATABASE" ]; then
    echo -e "${YELLOW}Creating user ${MYSQL_USER} and granting privileges...${NC}"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql -e "FLUSH PRIVILEGES;"
    echo -e "${GREEN}User created and privileges granted.${NC}"
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
