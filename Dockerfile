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

RUN apk add busybox-extras  \
    && curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin \
    && trivy rootfs --exit-code 1 --no-progress /

#RUN trivy image  --download-db-only
#RUN   TRIVY_TEMP_DIR=$(mktemp -d) \
#      && trivy --cache-dir $TRIVY_TEMP_DIR image --download-db-only \
#      && tar -cf ./db.tar.gz -C $TRIVY_TEMP_DIR/db metadata.json trivy.db \
#      && pwd && ls -la $TRIVY_TEMP_DIR 
  #    && rm -rf $TRIVY_TEMP_DIR

#RUN   mkdir -p reports \
#      && trivy image --scanners vuln --format template --template "@html.tpl" -o reports/CVE_report.html slc-it-la-marketplace-uat-registry.cn-beijing.cr.aliyuncs.com/slc-it-la-webhosting/cicd_demo1:0.2

#------------install sonar scanner -----------#
COPY sonar-scanner /usr/lib/sonar-scanner
RUN ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner && chmod +x /usr/local/bin/sonar-scanner
ENV SONAR_RUNNER_HOME=/usr/lib/sonar-scanner
    
COPY run.sh /usr/local/bin  
RUN ls -la /usr/local/bin 

RUN wget "https://dl.k8s.io/release/v1.26.3/bin/linux/amd64/kubectl"
RUN chmod +x kubectl
RUN mv ./kubectl /bin/kubectl

RUN mkdir /root/.kube
COPY k8s_config /root/.kube/config


    
RUN rm -rf /var/cache/apk/*

WORKDIR /usr/local/bin
RUN chmod +x run.sh
RUN chmod +x trivy

CMD ["sh","./run.sh"]
