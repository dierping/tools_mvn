FROM alpine:latest AS runtime
LABEL maintainer="erping.di@siemens.com"

USER root

ENV TZ Asia/Shanghai
RUN apk add alpine-conf && \
    /sbin/setup-timezone -z Asia/Shanghai && \
    apk del alpine-conf
    
#ADD repositories /etc/apk/repositories
RUN apk update \
    && apk add libcurl libc-utils libnfs zip unzip net-tools pstree libevent openssl git

RUN cat
