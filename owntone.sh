#!/bin/sh
# Start the D-Bus + Avahi stack that OwnTone's mDNS needs, robustly.

# 1) Clear stale runtime files. On a container restart the writable layer
#    persists, so a leftover dbus.pid/socket makes dbus-daemon refuse to start
#    ("Failed to start message bus: The pid file ... exists") -> Avahi can't
#    connect -> "mDNS init failed" -> crash-loop. Removing them fixes that.
mkdir -p /run/dbus
rm -f /run/dbus/dbus.pid /run/dbus/system_bus_socket /run/avahi-daemon/pid

dbus-uuidgen --ensure

# 2) Start system D-Bus and wait for its socket to appear.
dbus-daemon --system --fork
i=0
while [ ! -S /run/dbus/system_bus_socket ] && [ "$i" -lt 30 ]; do
    sleep 0.2; i=$((i + 1))
done

# 3) Start Avahi and wait until it is actually running before launching OwnTone
#    (owntone's mDNS init connects to Avahi over D-Bus and fails if it isn't up).
avahi-daemon --daemonize --no-chroot
i=0
while ! avahi-daemon --check 2>/dev/null && [ "$i" -lt 50 ]; do
    sleep 0.2; i=$((i + 1))
done

mkdir -p /config/cache
[ ! -f /config/owntone.conf ] && cp /etc/owntone.conf /config/owntone.conf

exec owntone -f -c /config/owntone.conf -P /var/run/owntone.pid
