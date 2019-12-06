#!/bin/sh

echo "starting MongoDB"

mkdir -p ${SERVICE_HOME} $(dirname ${SERVICE_LOGFILE})
#fix:adduser: user 'root' in use
if [ $SERVICE_USER = "root" ]; then
    echo "adduser: user 'root' in use" >/dev/null 2>&1
else
    adduser -u 1000 -D ${SERVICE_USER}
    chown -R ${SERVICE_USER}:${SERVICE_USER} ${SERVICE_HOME} $(dirname ${SERVICE_LOGFILE})
fi

mongod --version
#exec /usr/bin/mongod
mongod \
    --port ${SERVICE_PORT} \
    --dbpath ${SERVICE_HOME} \
    --logpath ${SERVICE_LOGFILE} \
    --logappend \
    -${SERVICE_LOGLEVEL}
#--config  /etc/conf.d/mongos.conf

echo "please wait - live logging in 5 secs ..."
sleep 5
tail -f ${SERVICE_LOGFILE}
