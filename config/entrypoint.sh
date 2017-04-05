#!/bin/bash

mkdir -p /data/feed-icons
chown -R www-data:www-data /data

if [ "x$MODE" == "xupdater" ]; then
    su -p -s /bin/bash -c "php /var/www/html/update.php --daemon" www-data
else
    apache2ctl -DFOREGROUND
fi
