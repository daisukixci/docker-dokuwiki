#!/usr/bin/env sh

ARCHIVE_DIR=$(tar -tvf  dokuwiki.tgz | sed -n 1p | awk '{print $6}' | cut -d/ -f1)
DATA_TEST='/var/www/localhost/htdocs/dokuwiki/data/pages'
CONF_TEST='/var/www/localhost/htdocs/dokuwiki/conf/dokuwiki.php'
PLUGINS_TEST='/var/www/localhost/htdocs/dokuwiki/lib/plugins/admin.php'
LIB_TEST='/var/www/localhost/htdocs/dokuwiki/lib/tpl/index.php'

init() {
    mkdir -p /var/www/localhost/htdocs/dokuwiki
    chown -R lighttpd:lighttpd /var/www/localhost/htdocs/dokuwiki
}

test_already_existing_instance() {
    file_test="$1"

    if [ -f "$file_test" ] || [ -d "$file_test" ]; then
        return 0
    fi
    return 1
}

deploy_part() {
    path="$1"

    sep="/"
    strip=$(( 2 + $(echo "$path" | awk -F"${sep}" '{print NF-1}')))

    tar xzvf dokuwiki.tgz -C "/var/www/localhost/htdocs/dokuwiki/${path}" \
        --strip-components "$strip" -- "${ARCHIVE_DIR}/${path}"
    chown -R lighttpd:lighttpd /var/www/localhost/htdocs/dokuwiki
}

echo "Actual version $(cat /var/www/localhost/htdocs/dokuwiki/VERSION)"

test_already_existing_instance "$DATA_TEST" || deploy_part "data"
test_already_existing_instance "$CONF_TEST" || deploy_part "conf"
test_already_existing_instance "$PLUGINS_TEST" || deploy_part "lib/plugins"
test_already_existing_instance "$LIB_TEST" || deploy_part "lib/tpl"

if [ "$1" == "run" ]; then
    exec /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf
else
    exec "$@"
fi
