FROM alpine:3.4
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

RUN sed -i -e 's/v3\.4/edge/g' /etc/apk/repositories && \
    apk -U add alpine-sdk coreutils && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /packages && \
    chown builder:abuild /packages && \
    su -c 'abuild-keygen -a -i -n' -l builder

COPY rustc /tmp/rustc
RUN cp -r /tmp/rustc /packages/ && \
    chown -R builder:abuild /packages/rustc && \
    su -c 'cd /packages/rustc && mkdir src && abuild -r' -l builder
