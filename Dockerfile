FROM debian:10 as builder

ENV TTRSS_VERSION=19.2

WORKDIR /source

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download TTRSS
RUN curl -L https://git.tt-rss.org/fox/tt-rss/archive/${TTRSS_VERSION}.tar.gz -o /ttrss.tar.gz \
    && tar xzf /ttrss.tar.gz -C /source --strip 1 && test -f /ttrss.tar.gz && rm -f /ttrss.tar.gz


FROM debian:10

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        ca-certificates \
        libapache2-mod-php7.3 \
        php7.3-cli \
        php7.3-curl \
        php7.3-gd \
        php7.3-intl \
        php7.3-json \
        php7.3-mbstring \
        php7.3-mysql \
        php7.3-pgsql \
        php7.3-xml \
        git \
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
RUN chown -R 1001:1001 /var/www/html && find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && chmod 777 cache/* feed-icons lock

COPY ./config/ttrss/config.php /var/www/html/config.php

COPY ./config/srv /srv/
RUN chmod +x /srv/*sh

VOLUME /data

ENV MODE=apache
EXPOSE 8080

USER 1001

CMD /srv/setup-ttrss.sh
