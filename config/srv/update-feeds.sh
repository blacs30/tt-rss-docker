#!/usr/bin/env sh

set -x

${UPDATE_INTERVAL:-5m}

while true; do
    cd /var/www/html
    exec php -f /var/www/html/update_daemon2.php
    sleep $UPDATE_INTERVAL
done
