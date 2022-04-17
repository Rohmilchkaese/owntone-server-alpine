#!/bin/sh

rm -rf /var/run
mkdir -p /var/run/dbus
dbus-uuidgen --ensure
sleep 1
dbus-daemon --system

avahi-daemon --daemonize --no-chroot

mkdir -p /config/cache
[[ ! -f /config/owntone.conf ]] && cp /etc/owntone.conf /config/owntone.conf ]]

exec owntone -f -c /config/owntone.conf -P /var/run/owntone.pid
