#!/bin/sh

sed -i "s/\([[:space:]]*host:\).*/\1 ${MYSQL_PORT_3306_TCP_ADDR}/g" /etc/redmine/default/database.yml
sed -i "s/\([[:space:]]*port:\).*/\1 ${MYSQL_PORT_3306_TCP_PORT}/g" /etc/redmine/default/database.yml

if [ -z "${REDMINE_SERVER_NAME}" ]; then
    sed -i "s/\([[:space:]]*ServerName\).*/\1 ${REDMINE_SERVER_NAME}/g" /etc/apache2/sites-available/redmine.conf
fi

if [ -z "${REDMINE_SERVER_ALIAS}" ]; then
    sed -i "s/\([[:space:]]*ServerAlias\).*/\1 ${REDMINE_SERVER_ALIAS}/g" /etc/apache2/sites-available/redmine-ssl.conf
fi

service apache2 start

echo "Executing $*"
exec $*

