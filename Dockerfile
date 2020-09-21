FROM ubuntu:20.04

ENV TTRSS_COMMIT_SHA=486f1d84ed

ENV TTRSS_PATH=/var/www/html
ENV TTRSS_PATH_THEMES=${TTRSS_PATH}/themes.local
ENV TTRSS_PATH_PLUGINS=${TTRSS_PATH}/plugins.local

#RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true; \
#    echo -e "tzdata tzdata/Areas select Europe\ntzdata tzdata/Zones/Europe select Amsterdam" > /tmp/tz ; \
#    debconf-set-selections /tmp/tz; \
#    dpkg-reconfigure -f non-interactive tzdata

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata


RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        ca-certificates \
        libapache2-mod-php7.4 \
        php7.4-cli \
        php7.4-curl \
        php7.4-gd \
        php7.4-intl \
        php7.4-json \
        php7.4-mbstring \
        php7.4-mysql \
        php7.4-pgsql \
        php7.4-xml \
        git \
        curl \
        sendmail \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/*

# configure apache to work with docker
RUN mkdir -p /var/log/apache2/ /var/run/apache2/ /var/lock/apache2/ \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stdout /var/log/apache2/error.log \
    && chmod 777 /var/log/apache2/ /var/run/apache2/ /var/lock/apache2/ \
    && a2disconf other-vhosts-access-log.conf \
    && a2enmod rewrite && a2enmod php7.4

COPY ./config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./config/apache/ports.conf /etc/apache2/ports.conf

WORKDIR ${TTRSS_PATH}

RUN git clone --depth=1 https://git.tt-rss.org/fox/tt-rss.git ${TTRSS_PATH} \
  && cd ${TTRSS_PATH} && git checkout ${TTRSS_COMMIT_SHA}

RUN  mkdir -p ${TTRSS_PATH_PLUGINS} \
  && git clone --depth=1 https://github.com/m42e/ttrss_plugin-feediron.git ${TTRSS_PATH_PLUGINS}/feediron \
  && git clone --depth=1 https://github.com/DigitalDJ/tinytinyrss-fever-plugin ${TTRSS_PATH_PLUGINS}/fever \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-mailer-smtp.git ${TTRSS_PATH_PLUGINS}/mailer_smtp \
  && git clone --depth=1 https://git.tt-rss.org/fox/ttrss-time-to-read.git ${TTRSS_PATH_PLUGINS}/time_to_read \
  && mkdir -p ${TTRSS_PATH_THEMES} \
  && git clone --depth=1 https://github.com/levito/tt-rss-feedly-theme.git ${TTRSS_PATH_THEMES}/levito-feedly-git \
  && git clone --depth=1 https://github.com/Gravemind/tt-rss-feedlish-theme.git ${TTRSS_PATH_THEMES}/gravemind-feedly-git \
  && cp -r ${TTRSS_PATH_THEMES}/levito-feedly-git/feedly* ${TTRSS_PATH_THEMES}/ \
  && cp -r ${TTRSS_PATH_THEMES}/gravemind-feedly-git/*css ${TTRSS_PATH_THEMES}/ \
  && cp -r ${TTRSS_PATH_THEMES}/gravemind-feedly-git/*less ${TTRSS_PATH_THEMES}/ \
  && curl -L https://raw.githubusercontent.com/jonathanherrmannengel/tt-rss_reeder_theme/master/ijreeder.css -o ${TTRSS_PATH_THEMES}/ijreeder.css

# configure file permissions for ttrss
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
