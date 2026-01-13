#!/bin/sh

echo "Wordpress script: running script"

if [ ! -f "wp-config.php" ]; then

    echo "Wordpress script: Starting installation"
    
    # Download and unzip
    wget https://wordpress.org/latest.tar.gz
    tar -xzvf latest.tar.gz --strip-components=1
    rm latest.tar.gz

    # download wp-cli
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    echo "Wordpress script: wp-cli installed"

    # Secrets
    database_passwd=$(cat /run/secrets/database_passwd)
    wp_admin_passwd=$(cat /run/secrets/wp_admin_passwd)
    wp_editor_passwd=$(cat /run/secrets/wp_editor_passwd)

    # Connect to mariadb database
    while ! mariadb -h mariadb -u$database_user -p$database_passwd $database_name &>/dev/null; do
        sleep 1
    done
    echo "Wordpress script: MariaDB is ready"

    # Edit Config file wp-config.php to add database informations
    wp config create --dbname=$database_name \
                     --dbuser=$database_user \
                     --dbpass=$database_passwd \
                     --dbhost=mariadb \
                     --allow-root

    echo "Wordpress script: wp-config.php created"

    # install wp, create database tables
    wp core install --url=$domain_name \
                    --title=$wp_title \
                    --admin_user=$wp_admin_user \
                    --admin_password=$wp_admin_passwd \
                    --admin_email=$wp_admin_email \
                    --allow-root

    echo "Wordpress script: wp core installed"

    # creating editor user
    wp user create $wp_editor_user $wp_editor_email \
                   --user_pass=$wp_editor_passwd \
                   --role=editor \
                   --allow-root

    # install theme
    if ! wp theme is-installed ember-dawn; then
        wp theme install ember-dawn
    fi
    
    echo "Wordpress script: activating Ember Dawn theme"
    wp theme activate ember-dawn
    
    # Connect to redis
    echo "Wordpress script: waiting for redis"
    while ! redis-cli -h redis ping | grep PONG &>/dev/null; do
        sleep 1
    done

    echo "Wordpress script: Redis is ready"

    wp plugin install redis-cache --activate --allow-root
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp redis enable --allow-root

    echo "Wordpress script: Redis installed"

    # cleanup
    unset database_passwd
    unset wp_admin_passwd
    unset wp_editor_passwd

fi

echo "Wordpress script: Fixing permissions"
chown -R 1000:1000 /var/www/html

echo "Wordpress script: exec php fpm"
exec php-fpm83 -F