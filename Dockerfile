FROM alpine:3.7

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
    php5-dom

# Download & check & deploy dokuwiki & cleanup
RUN wget -q -O /dokuwiki.tgz "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz" \
    && mkdir -p /var/www/localhost/htdocs/dokuwiki \
    && tar -zxf dokuwiki.tgz -C /var/www/localhost/htdocs/dokuwiki --strip-components 1

# Set up ownership
RUN chown -R lighttpd:lighttpd /var/www/localhost/htdocs/dokuwiki

# Configure lighttpd
ADD etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf
ADD etc/lighttpd/mod_fastcgi.conf /etc/lighttpd/mod_fastcgi.conf
RUN chown -R lighttpd:lighttpd /etc/lighttpd/
RUN mkdir /run/lighttpd
RUN chown -R lighttpd. /run/lighttpd

EXPOSE 80
VOLUME ["/var/www/localhost/htdocs/dokuwiki/conf", \
        "/var/www/localhost/htdocs/dokuwiki/data", \
        "/var/www/localhost/htdocs/dokuwiki/lib/plugins"]

ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
