FROM alpine:3.18

ENV DOKUWIKI_VERSION="stable"
ENV ARCHIVE_URL="https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz"

# Update & install packages & cleanup afterwards
RUN apk update && apk upgrade && apk add \
    fcgi \
    git \
    lighttpd \
    php82-common \
    php82-session \
    php82-iconv \
    php82-json \
    php82-gd \
    php82-curl \
    php82-xml \
    php82-mysqli \
    php82-imap \
    php82-cgi \
    php82-pdo \
    php82-pdo_mysql \
    php82-soap \
    php82-posix \
    php82-gettext \
    php82-ldap \
    php82-ctype \
    php82-dom \
    php82-simplexml

# Download & check & deploy dokuwiki & cleanup
RUN wget -q -O /dokuwiki.tgz ${ARCHIVE_URL} \
    && mkdir -p /var/www/localhost/htdocs/dokuwiki \
    && tar -zxf /dokuwiki.tgz -C /var/www/localhost/htdocs/dokuwiki --strip-components 1

# Set up ownership
RUN chown -R lighttpd:lighttpd /var/www/localhost/htdocs/dokuwiki

# Configure lighttpd
ADD etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf
ADD etc/lighttpd/mod_fastcgi.conf /etc/lighttpd/mod_fastcgi.conf
RUN chown -R lighttpd:lighttpd /etc/lighttpd/
RUN mkdir /run/lighttpd
RUN chown -R lighttpd. /run/lighttpd

# Add entrypoint
COPY entrypoint.sh /

EXPOSE 80
VOLUME ["/var/www/localhost/htdocs/dokuwiki/conf", \
    "/var/www/localhost/htdocs/dokuwiki/data", \
    "/var/www/localhost/htdocs/dokuwiki/lib/tpl", \
    "/var/www/localhost/htdocs/dokuwiki/lib/plugins"]

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD wget -q http://localhost/doku.php -O /dev/null || exit 1
CMD ["run"]
