#!/bin/bash

mkdir -p /data/feed-icons

if [ "x$MODE" == "xupdater" ]; then
    exec php /var/www/html/update.php --daemon
else
    exec apache2ctl -DFOREGROUND
fi
