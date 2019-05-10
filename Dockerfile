FROM debian:9 as builder
WORKDIR /source

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download TTRSS
RUN git clone --depth 1 https://git.tt-rss.org/fox/tt-rss.git /source



FROM debian:9

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        ca-certificates \
        libapache2-mod-php7.0 \
        php7.0-cli \
        php7.0-curl \
        php7.0-gd \
        php7.0-intl \
        php7.0-json \
        php7.0-mbstring \
        php7.0-mysql \ 
        php7.0-xml \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/*

# configure apache to work with docker
RUN mkdir -p /var/log/apache2/ /var/run/apache2/ /var/lock/apache2/ \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stdout /var/log/apache2/error.log \
    && chmod 777 /var/log/apache2/ /var/run/apache2/ /var/lock/apache2/ \
    && a2disconf other-vhosts-access-log.conf \
    && a2enmod rewrite 

COPY ./config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./config/apache/ports.conf /etc/apache2/ports.conf

WORKDIR /var/www/html
COPY --from=builder /source /var/www/html

# configure file permissions for ttrss
RUN find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && chmod 777 cache/* feed-icons lock

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
