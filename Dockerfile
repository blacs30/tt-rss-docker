FROM debian:10

ENV TTRSS_VERSION=19.8

ENV TTRSS_PATH=/var/www/html
ENV TTRSS_PATH_THEMES=${TTRSS_PATH}/themes.local
ENV TTRSS_PATH_PLUGINS=${TTRSS_PATH}/plugins.local

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
        curl \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/*

# configure apache to work with docker
RUN mkdir -p /var/log/apache2/ /var/run/apache2/ /var/lock/apache2/ \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stdout /var/log/apache2/error.log \
    && chmod 777 /var/log/apache2/ /var/run/apache2/ /var/lock/apache2/ \
    && a2disconf other-vhosts-access-log.conf \
    && a2enmod rewrite && a2enmod php7.3

COPY ./config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./config/apache/ports.conf /etc/apache2/ports.conf

WORKDIR ${TTRSS_PATH}

RUN curl -L https://git.tt-rss.org/fox/tt-rss/archive/${TTRSS_VERSION}.tar.gz -o /ttrss.tar.gz \
  && tar xzf /ttrss.tar.gz -C ${TTRSS_PATH} --strip 1 && test -f /ttrss.tar.gz && rm -f /ttrss.tar.gz

RUN  mkdir -p ${TTRSS_PATH_PLUGINS} \
  && git clone --depth=1 https://github.com/sepich/tt-rss-mobilize.git ${TTRSS_PATH_PLUGINS}/mobilize \
  && git clone --depth=1 https://github.com/m42e/ttrss_plugin-feediron.git ${TTRSS_PATH_PLUGINS}/feediron \
  && git clone --depth=1 https://github.com/DigitalDJ/tinytinyrss-fever-plugin ${TTRSS_PATH_PLUGINS}/fever \
  && mkdir -p ${TTRSS_PATH_THEMES} \
  && git clone --depth=1 https://github.com/levito/tt-rss-feedly-theme.git ${TTRSS_PATH_THEMES}/levito-feedly-git \
  && git clone --depth=1 https://github.com/Gravemind/tt-rss-feedlish-theme.git ${TTRSS_PATH_THEMES}/gravemind-feedly-git

# configure file permissions for ttrss
RUN ls -la /var/www/html


RUN chown -R 1001:1001 /var/www/html && find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && chmod 777 cache/* feed-icons lock

COPY ./config/ttrss/config.php /var/www/html/config.php

COPY ./config/srv /srv/
RUN chmod +x /srv/*sh && chown -R 1001:1001 /srv

VOLUME /data

ENV MODE=apache
EXPOSE 8080

USER 1001

CMD /srv/setup-ttrss.sh
