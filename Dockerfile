FROM alpine:3.12.0

RUN apk --no-cache add --virtual=deps1 \
        alsa-lib-dev \
        autoconf \
        automake \
        avahi-dev \
        bash \
        bsd-compat-headers \
        build-base \
        confuse-dev \
        curl \
        curl-dev \
        ffmpeg-dev \
        file \
        git \
        gnutls-dev \
        gperf \
        json-c-dev \
        libevent-dev \
        libgcrypt-dev \
        libplist-dev \
        libsodium-dev \
        libtool \
        libunistring-dev \
	libwebsockets-dev \
        openjdk8-jre-base \
        protobuf-c-dev \
        sqlite-dev \
 && apk add --no-cache --virtual=deps2 --repository http://nl.alpinelinux.org/alpine/edge/testing \
        libantlr3c-dev \
        mxml-dev \
 && apk add --no-cache \
        avahi \
        confuse \
        dbus \
        ffmpeg \
        json-c \
        libcurl \
        libevent \
        libgcrypt \
        libplist \
        libsodium \
        libunistring \
        protobuf-c \
        sqlite \
        sqlite-libs \
	libwebsockets-dev \
 && apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/testing \
        libantlr3c \
        mxml \
        #pulseaudio-libs \
 && curl -L -o /tmp/antlr-3.4-complete.jar http://www.antlr3.org/download/antlr-3.4-complete.jar \
 && echo '#!/bin/bash' > /usr/local/bin/antlr3 \
 && echo 'exec java -cp /tmp/antlr-3.4-complete.jar org.antlr.Tool "$@"' >> /usr/local/bin/antlr3 \
 && chmod 775 /usr/local/bin/antlr3 \
 && cd /tmp \
 && git clone https://github.com/ejurgensen/forked-daapd.git \
 && cd /tmp/forked-daapd \
 && autoreconf -i \
 && ./configure \
	--enable-chromecast \
        --enable-itunes \
        --enable-lastfm \
        --enable-mpd \
        --infodir=/usr/share/info \
        --localstatedir=/var \
        --mandir=/usr/share/man \
        --prefix=/usr \
        --sysconfdir=/etc \
 && make \
 && make install \
 && apk del --purge deps1 deps2 \
 && rm -rf /usr/local/bin/antlr3 /tmp/* \
 && cd /etc \
 && sed -i -e 's/\(uid.*=.*\)/uid = "root"/g' forked-daapd.conf \
 && sed -i s#"ipv6 = yes"#"ipv6 = no"#g forked-daapd.conf \
 && sed -i s#/srv/music#/music#g forked-daapd.conf \
 && sed -i s#/usr/local/var/cache/forked-daapd/songs3.db#/config/cache/songs3.db#g forked-daapd.conf \
 && sed -i s#/usr/local/var/cache/forked-daapd/cache.db#/config/cache/cache.db#g forked-daapd.conf \
 && sed -i s#/usr/local/var/log/forked-daapd.log#/dev/stdout#g forked-daapd.conf \
 && sed -i "/db_path\ =/ s/# *//" forked-daapd.conf \
 && sed -i "/cache_path\ =/ s/# *//" forked-daapd.conf

VOLUME /config /music
COPY daapd.sh /start
RUN chmod +x /start
ENTRYPOINT [ "/start" ]
