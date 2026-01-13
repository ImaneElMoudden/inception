#!/bin/sh

sed -i "s|^skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf
# allow mariadb to listen on tcp ip ports
# allow all incoming connection requests

# the directory for mariadb socket file, change the owner to mysql
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# check if the database is initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Mariadb: Initializing database"

    # secrets
    database_passwd=$(cat /run/secrets/database_passwd)
    root_passwd=$(cat /run/secrets/root_passwd)

    # install mariadb's database files and internal tables for users who try to connect
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # start a temporary server in the background to execute the SQL commands
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid=$!

    # Wait for the server to be ready
    echo "Mariadb: Waiting for server to start"
    while ! mariadb-admin ping &>/dev/null; do
        sleep 1
    done

    # mariadb configuration
    echo "Mariadb: configuring database"
    mariadb -u root <<EOF

CREATE DATABASE IF NOT EXISTS $database_name;

CREATE USER IF NOT EXISTS '$database_user'@'%' IDENTIFIED BY '$database_passwd';
GRANT ALL PRIVILEGES ON $database_name.* TO '$database_user'@'%';

# add a passwd to root user
ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_passwd';

# for safety, remove anonymous users
DELETE FROM mysql.user WHERE User='';

# remove remote root login
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

# remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

FLUSH PRIVILEGES;
EOF

    echo "mariadb: stopping server"
    mariadb-admin -u root -p$root_passwd shutdown
    wait $pid

    # cleanup
    unset database_passwd
    unset root_passwd
    echo "Mariadb: database initialized"
fi

echo "Mariadb: starting server"
exec mysqld --user=mysql
