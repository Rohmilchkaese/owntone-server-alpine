FROM alpine:3.17.2

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
        flex \
 && apk add --no-cache --virtual=deps2 --repository http://nl.alpinelinux.org/alpine/edge/testing \
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
       libuuid \
 && apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/testing \
        mxml \
        bison \
        flex \
        #pulseaudio-libs \
 && cd /tmp \
 && git clone https://github.com/owntone/owntone-server.git \
 && cd /tmp/owntone-server \
 && git checkout tags/28.6 \
 && autoreconf -i \
 && ./configure \
#	 --enable-chromecast \
        --enable-itunes \
#        --enable-mpd \
         --disable-mpd \
         --disable-spotify \
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
 && sed -i -e 's/\(uid.*=.*\)/uid = "root"/g' owntone.conf \
 && sed -i s#"ipv6 = yes"#"ipv6 = no"#g owntone.conf \
 && sed -i s#/srv/music#/music#g owntone.conf \
 && sed -i s#/usr/local/var/cache/owntone/songs3.db#/config/cache/songs3.db#g owntone.conf \
 && sed -i s#/usr/local/var/cache/owntone/cache.db#/config/cache/cache.db#g owntone.conf \
 && sed -i s#/usr/local/var/log/owntone.log#/dev/stdout#g owntone.conf \
 && sed -i "/db_path\ =/ s/# *//" owntone.conf \
 && sed -i "/cache_path\ =/ s/# *//" owntone.conf

VOLUME /config /music
COPY owntone.sh /start
RUN chmod +x /start
ENTRYPOINT [ "/start" ]
