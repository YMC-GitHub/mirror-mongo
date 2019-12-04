FROM alpine:3.9.4
LABEL MAINTAINER="ymc-github <yemiancheng@gmail.com>"
ARG SERVICE_USER
ARG SERVICE_HOME
ARG SERVICE_PORT
ARG SERVICE_LOGFILE
ARG SERVICE_LOGLEVEL
ENV SERVICE_USER ${SERVICE_USER:-root}
ENV SERVICE_HOME ${SERVICE_HOME:-/data/db/mongo}
ENV SERVICE_PORT ${SERVICE_PORT:-27017}
ENV SERVICE_LOGFILE ${SERVICE_LOGFILE:-/data/log/mongod.log}
ENV SERVICE_LOGLEVEL ${SERVICE_LOGLEVEL:-v}
ENV TIMEZONE Asia/Shanghai
COPY startup.sh /startup.sh
RUN   sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories &&     apk add --update dumb-init mongodb && rm -f /var/cache/apk/* &&     chmod +x /startup.sh
    
USER    ${SERVICE_USER}
WORKDIR ${SERVICE_HOME}
VOLUME  ${SERVICE_HOME}
EXPOSE  ${SERVICE_PORT}
CMD ["/startup.sh"]
