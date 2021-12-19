FROM alpine:3.15

ENV DOKUWIKI_VERSION="stable"
ENV ARCHIVE_URL="https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz"

# Update & install packages & cleanup afterwards
RUN apk update && apk upgrade && apk add \
    lighttpd \
    php7-common \
    php7-session \
    php7-iconv \
    php7-json \
    php7-gd \
    php7-curl \
    php7-xml \
    php7-mysqli \
    php7-imap \
    php7-cgi \
    fcgi \
    php7-pdo \
    php7-pdo_mysql \
    php7-soap \
    php7-xmlrpc \
    php7-posix \
    php7-mcrypt \
    php7-gettext \
    php7-ldap \
    php7-ctype \
    php7-dom \
    php7-simplexml \
    git

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
