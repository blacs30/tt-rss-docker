#!/bin/bash

mkdir -p /data/feed-icons

if [ "x$MODE" == "xupdater" ]; then
    echo -e "yes\n" | php /var/www/html/update.php --update-schema
    exec php /var/www/html/update.php --daemon
else
    exec apache2ctl -DFOREGROUND
fi
