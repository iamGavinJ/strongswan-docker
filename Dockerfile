#
# StrongSwan VPN + Alpine Linux
#
# Build with: docker build -t iamgavinj/strongswan:latest -t iamgavinj/strongswan:5.7.2 .

FROM alpine:edge

ENV STRONGSWAN_RELEASE https://download.strongswan.org/strongswan.tar.bz2

RUN apk update && \
    apk upgrade && \
    apk --update --no-cache add \
            build-base \
            ca-certificates \
            curl \
            curl-dev \
            ip6tables \
            iproute2 \
            iptables-dev \
            openssl \
            openssl-dev && \
    mkdir -p /lib/modules && \
    mkdir -p /var/run/strongswan && \
    chmod -R 777 /var/run/strongswan && \
    mkdir -p /tmp/strongswan && \
    curl -Lo /tmp/strongswan.tar.bz2 $STRONGSWAN_RELEASE && \
    tar --strip-components=1 -C /tmp/strongswan -xjf /tmp/strongswan.tar.bz2 && \
    cd /tmp/strongswan && \
    ./configure --prefix=/usr \
            --sysconfdir=/etc/strongswan \
            --localstatedir=/var \
            --runstatedir=/var/run/strongswan \
            --with-resolv-conf=/etc/resolv.conf \
            --enable-aesni \
            --disable-aes \
            --enable-chapoly \
            --enable-curl \
            --enable-files \
            --enable-gcm \
            --enable-openssl \
            --enable-cmd \
            --enable-dhcp \
            --enable-eap-dynamic \
            --enable-eap-identity \
            --enable-eap-md5 \
            --enable-eap-peap \
            --enable-eap-radius \
            --enable-eap-tls \
            --enable-eap-ttls \
            --enable-farp \
            --enable-radattr \
            --enable-xauth-eap \
            --enable-newhope \
            --enable-ntru \
            --enable-sha3 \
            --enable-shared \
            --disable-ikev1 \
            --disable-gmp \
            --disable-des \
            --disable-rc2 \
            --disable-sha1 \
            --disable-static && \
    make && \
    make install clean && \
    rm -rf /tmp/* && \
    apk del build-base curl-dev openssl-dev && \
    rm -rf /var/cache/apk/*

EXPOSE 500/udp \
       4500/udp

ENTRYPOINT ["/usr/sbin/ipsec"]
CMD ["start", "--nofork"]
