#!/bin/sh -x

npm run start-onprem &

/usr/sbin/httpd -f /etc/apache2/httpd.conf -DFOREGROUND

