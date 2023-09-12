FROM alpine:latest
LABEL maintainer="erping.di@siemens.com"

USER root
#ADD repositories /etc/apk/repositories
RUN apk update \
    && apk add libcurl libc-utils libnfs zip unzip net-tools pstree libevent openssl \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
