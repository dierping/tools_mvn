FROM alpine:latest AS runtime
LABEL maintainer="erping.di@siemens.com"

USER root

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache docker-cli curl libcurl libc-utils libnfs zip unzip net-tools pstree libevent openssl git openssh-client

ENV TZ Asia/Shanghai
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
    
#RUN apk --no-cache add ca-certificates \ 
#    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \ 
#    && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk \ 
#    && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-bin-2.29-r0.apk \
#    && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-i18n-2.29-r0.apk \
#    && apk add glibc-2.29-r0.apk glibc-bin-2.29-r0.apk glibc-i18n-2.29-r0.apk \
#    && rm -rf /usr/lib/jvm glibc-2.29-r0.apk glibc-bin-2.29-r0.apk  glibc-i18n-2.29-r0.apk \
#    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
#    && echo "export LANG=$LANG" > /etc/profile.d/locale.sh 
  #  && apk del glibc-i18n

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
    
#ADD repositories /etc/apk/repositories
RUN apk update

RUN apk add busybox-extras \
    && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin \
    && trivy rootfs --exit-code 1 --no-progress /
    

RUN wget "https://dl.k8s.io/release/v1.26.3/bin/linux/amd64/kubectl"
RUN chmod +x kubectl
RUN mv ./kubectl /bin/kubectl

RUN mkdir /root/.kube
COPY k8s_config /root/.kube/config


    
RUN rm -rf /var/cache/apk/*

ENTRYPOINT ["while true do sleep 600 done"]
