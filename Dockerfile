FROM alpine:3.7

ENV DOKUWIKI_VERSION="stable"
ENV ARCHIVE_URL="https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz"

# Update & install packages & cleanup afterwards
RUN apk update && apk upgrade && apk add \
    lighttpd \
    php5-common \
    php5-iconv \
    php5-json \
    php5-gd \
    php5-curl \
    php5-xml \
    php5-pgsql \
    php5-mysql \
    php5-imap \
    php5-cgi \
    fcgi \
    php5-pdo \
    php5-pdo_pgsql \
    php5-pdo_mysql \
    php5-soap \
    php5-xmlrpc \
    php5-posix \
    php5-mcrypt \
    php5-gettext \
    php5-ldap \
    php5-ctype \
    php5-openssl \
    php5-zlib \
    php5-dom

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
CMD ["run"]
