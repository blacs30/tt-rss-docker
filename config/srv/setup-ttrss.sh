#!/bin/bash
set -x

setup_ttrss()
{
   	TTRSS_PATH=/var/www/html
    TTRSS_PATH_THEMES=${TTRSS_PATH}/themes.local
    TTRSS_PATH_PLUGINS=${TTRSS_PATH}/plugins.local

    echo "Setup plugins and themes"
    mkdir -p ${TTRSS_PATH_PLUGINS}
    git clone --depth=1 https://github.com/sepich/tt-rss-mobilize.git ${TTRSS_PATH_PLUGINS}/mobilize
    git clone --depth=1 https://github.com/m42e/ttrss_plugin-feediron.git ${TTRSS_PATH_PLUGINS}/feediron
    git clone --depth=1 https://github.com/DigitalDJ/tinytinyrss-fever-plugin ${TTRSS_PATH_PLUGINS}/fever

    mkdir -p ${TTRSS_PATH_THEMES}
    git clone --depth=1 https://github.com/levito/tt-rss-feedly-theme.git ${TTRSS_PATH_THEMES}/levito-feedly-git
    git clone --depth=1 https://github.com/Gravemind/tt-rss-feedlish-theme.git ${TTRSS_PATH_THEMES}/gravemind-feedly-git

    # Enable additional system plugins.
    if [ -z ${TTRSS_PLUGINS} ]; then

        TTRSS_PLUGINS=

        # Only if SSL/TLS is enabled: af_zz_imgproxy (Loads insecure images via built-in proxy).
        if [ "$TTRSS_PROTO" = "https" ]; then
            TTRSS_PLUGINS=${TTRSS_PLUGINS}af_zz_imgproxy
        fi
    fi

    echo "Setup: Additional plugins: $TTRSS_PLUGINS"

    sed -i -e "s/.*define('PLUGINS'.*/define('PLUGINS', '$TTRSS_PLUGINS, auth_internal, note, updater');/g" ${TTRSS_PATH}/config.php
}

setup_db()
{
    echo "Setup: Database"
    php -f /srv/ttrss-configure-db.php
    php -f /srv/ttrss-configure-plugin-mobilize.php
}

setup_ttrss
setup_db

if [ -z "$ICONS_DIR" ]; then
    mkdir -p /var/www/html/feed-icons && chmod -R 777 /var/www/html/feed-icons
else
    test -d "$ICONS_DIR" || mkdir -p "$ICONS_DIR"
    chmod -R 777 "$ICONS_DIR"
fi

if [ "x$MODE" == "xupdater" ]; then
    echo -e "yes\n" | php /var/www/html/update.php --update-schema
    echo "Setup: Applying updates ..."
    exec php /var/www/html/update.php --daemon
else
    exec /srv/update-feeds.sh &
    exec apache2ctl -DFOREGROUND
fi
