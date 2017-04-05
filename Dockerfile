FROM debian:8

RUN apt-get update && apt-get install -y \
        apache2 \
        git \
        php5 \
        php5-curl \
        php5-gd \
        php5-mcrypt \
        php5-mysql
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -Rf /var/www/html/* && git clone https://tt-rss.org/git/tt-rss.git /var/www/html

WORKDIR /var/www/html
RUN chown www-data:www-data cache/images cache/upload cache/export cache/js feed-icons lock

COPY ./config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

COPY ./config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /data
RUN ln -s /data/config.php /var/www/html/
RUN rm -Rf /var/www/html/feed-icons && ln -s /data/feed-icons /var/www/html/

ENV MODE=apache
EXPOSE 80

CMD /entrypoint.sh
