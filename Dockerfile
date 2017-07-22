FROM debian:8

RUN apt-get update && apt-get install -y \
        apache2 \
        git \
        php5 \
        php5-curl \
        php5-gd \
        php5-mcrypt \
        php5-mysql \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# get TTRSS
RUN rm -Rf /var/www/html/* && git clone https://tt-rss.org/git/tt-rss.git /var/www/html

# configure apache to work with docker
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stdout /var/log/apache2/error.log \
    && chmod 777 /var/log/apache2/ /var/run/apache2/ /var/lock/apache2/ \
    && a2disconf other-vhosts-access-log.conf \
    && a2enmod rewrite 

COPY ./config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./config/apache/ports.conf /etc/apache2/ports.conf

WORKDIR /var/www/html

# configure file permissions for ttrss
RUN find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && chmod 777 cache/images cache/upload cache/export cache/js feed-icons lock

COPY ./config/ttrss/config.php /var/www/html/config.php

COPY ./config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /data
RUN ln -s /data/config.php /var/www/html/config-user.php \
    && rm -Rf /var/www/html/feed-icons \
    && ln -s /data/feed-icons /var/www/html/ \
    && ln -s /data/.htaccess /var/www/html/

ENV MODE=apache
EXPOSE 8080

USER 1001

CMD /entrypoint.sh
