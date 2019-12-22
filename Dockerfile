FROM alpine:3.10.4
LABEL MAINTAINER="ymc-github <yemiancheng@gmail.com>"
ARG SERVICE_USER
ARG SERVICE_HOME
ARG SERVICE_PORT
ARG SERVICE_LOGFILE
ARG SERVICE_LOGLEVEL
ARG SERVICE_VERSION
ARG SERVICE_IP
ENV SERVICE_USER ${SERVICE_USER:-root}
ENV SERVICE_HOME ${SERVICE_HOME:-/data/db/mongo}
ENV SERVICE_PORT ${SERVICE_PORT:-27017}
ENV SERVICE_LOGFILE ${SERVICE_LOGFILE:-/data/log/mongod.log}
ENV SERVICE_LOGLEVEL ${SERVICE_LOGLEVEL:-v}
ENV SERVICE_VERSION ${SERVICE_VERSION:-4.0.5-r0}
ENV SERVICE_IP ${SERVICE_IP:-0.0.0.0}
ENV TIMEZONE Asia/Shanghai
COPY startup.sh /startup.sh
RUN   sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories &&     apk add --update dumb-init mongodb=${SERVICE_VERSION} && rm -f /var/cache/apk/* &&     chmod +x /startup.sh
    
USER    ${SERVICE_USER}
WORKDIR ${SERVICE_HOME}
VOLUME  ${SERVICE_HOME}
EXPOSE  ${SERVICE_PORT}
CMD ["/startup.sh"]
