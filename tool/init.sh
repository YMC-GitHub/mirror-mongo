#!/bin/sh

THIS_FILE_PATH=$(
    cd $(dirname $0)
    pwd
)
source $THIS_FILE_PATH/function-list.sh
THIS_PROJECT_PATH=$(path_resolve "$THIS_FILE_PATH" "../")
RUN_SCRIPT_PATH=$(pwd)
buildlogfile=$THIS_PROJECT_PATH/tool/build-log.txt

function add_dockerfile() {
    local author=
    local email=
    local TXT=
    author=ymc-github
    email=yemiancheng@gmail.com
    local TXT=
    TXT=$(
        cat <<EOF
# base mongo image with alpine
# 基础镜像
#FROM alpine:3.7.3
#FROM alpine:3.9.4
FROM alpine:3.10.4
# 维护作者
LABEL MAINTAINER="${author} <${email}>"
# 可选参数
ARG SERVICE_USER
ARG SERVICE_HOME
ARG SERVICE_PORT
ARG SERVICE_LOGFILE
ARG SERVICE_LOGLEVEL

# 默认设置
ENV SERVICE_USER \${SERVICE_USER:-root}
ENV SERVICE_HOME \${SERVICE_HOME:-/data/db/mongo}
ENV SERVICE_PORT \${SERVICE_PORT:-27017}
ENV SERVICE_LOGFILE \${SERVICE_LOGFILE:-/data/log/mongod.log}
ENV SERVICE_LOGLEVEL \${SERVICE_LOGLEVEL:-v}
ENV TIMEZONE Asia/Shanghai

# 拷贝脚本
#COPY ./entrypoint.sh /
COPY startup.sh /startup.sh

# 创建目录+添加用户+更改所属+用国内源+安装软件+赋执行权
#adduser -h \${SERVICE_HOME} -s /sbin/nologin -u 1000 -D \${SERVICE_USER}
#RUN \
#  mkdir -p \${SERVICE_HOME} \$(dirname \${SERVICE_LOGFILE}) && \
#  adduser  -u 1000 -D \${SERVICE_USER} && \
#  chown -R \${SERVICE_USER}:\${SERVICE_USER} \${SERVICE_HOME} \$(dirname \${SERVICE_LOGFILE}) && \
#  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
#    apk add --update dumb-init mongodb && rm -f /var/cache/apk/* && \
#    chmod +x /startup.sh
#chmod +x /entrypoint.sh

RUN \
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --update dumb-init mongodb && rm -f /var/cache/apk/* && \
    chmod +x /startup.sh
    
# 服务用户
USER    \${SERVICE_USER}
# 工作目录
WORKDIR \${SERVICE_HOME}
# 挂数据卷
VOLUME  \${SERVICE_HOME}
# 暴露端口
EXPOSE  \${SERVICE_PORT}
#ENTRYPOINT [ "/entrypoint.sh" ]
#ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["/startup.sh"]

EOF
    )
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT"
}

function add_dockerignore() {
    local TXT=
    TXT=$(
        cat <<EOF
.git
LICENSE
README.md
tool/
EOF
    )
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT"
}

function add_license() {
    local author=
    local email=
    local TXT=
    author=ymc-github
    email=yemiancheng@gmail.com
    local TXT=
    TXT=$(
        cat <<EOF
The MIT License (MIT)

Copyright (c) 2019 ${author} <${email}>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
    )
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT"
}

function add_readme() {
    local author=
    local email=
    local TXT=
    local TXT=
    local temp=
    author=ymc-github
    email=yemiancheng@gmail.com
    temp=$(cat $buildlogfile)
    TXT=$(
        cat <<EOF
# alpine-mongo

## desc

a docker image base on alpine with mongo

## how to use with developer?

### define config
\`\`\`
cat >tool/hub_list.txt <<EOF
#repo-owner-pass
#hub.docker.com=your user =your pass
registry.cn-hangzhou.aliyuncs.com=xxx=xxx
 EOF
\`\`\`


\`\`\`
cat >tool/img_list.txt <<EOF
#name-label=name-label
mongo-alpine-3.8.4=mongo-alpine-3.8.4
mongo-alpine-3.9.4=mongo-alpine-3.9.4
#mongo-alpine-3.10.3=mongo-alpine-3.10.3
 EOF
\`\`\`


### build image
build the image with your config
\`\`\`
./tool/build.sh
\`\`\`

it will build image mongo:alpine-3.8.4 and mongo:alpine-3.9.4 .

the mongo:alpine-3.10.3 will not be build with \`#\` comment.

### test image
test the image you build
\`\`\`
./tool/test.sh
\`\`\`

it will test image mongo:alpine-3.8.4 and mongo:alpine-3.9.4 .

### push image

tag and push the image to some docker hub ,eg. docker hub ,aliyun,qiniu ...
\`\`\`
img_ns=yemiancheng
./tool/push.sh "\$img_ns"
\`\`\`

it will tag image for docker hub registry.cn-hangzhou.aliyuncs.com ,so there will be:
\`\`\`
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.8.4
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.9.4
\`\`\`

the hub.docker.com will not be taged with \`#\` comment.


it will push image :
\`\`\`
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.8.4
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.9.4
\`\`\`

the hub.docker.com will not be pushed with \`#\` comment.

so that you need to set pass in tool/hub_list.txt . and for secure dont let other person know it.

## how to use with production ?

### pull image with docker cli
\`\`\`
tag=registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-X.X.X
docker pull "\$tag"
\`\`\`

### run image with docker cli
\`\`\`
docker run -d --name mongo -p 3306:3306 -v \$(pwd):/app -e mongo_DATABASE=admin -e mongo_USER=huahua -e mongo_PASSWORD=MjAxOS -e mongo_ROOT_PASSWORD=jo1NQo "\$tag"
\`\`\`

note:in the .env file , you can change the different values to suit your needs.

### uses with a dockerfile 
\`\`\`
FROM registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.9.4
\`\`\`

your can run with docker cli :
\`\`\`
docker run -v /mongo/data/:/var/lib/mongo -d -p 3306:3306 --name mongo-alpine-3.9.4 where/your/dockerfile
\`\`\`

or your can run with docker-compose ,

or your can run with k8s .

## building log

\`\`\`
$temp
\`\`\`

EOF
    )
    #TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT"
}

function add_gitignore() {
    local TXT=
    TXT=$(
        cat <<EOF
mongo
tool/hub_list.txt
tool/img_list.txt
EOF
    )
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT"
}

function main_fun() {
    local path=
    local TXT=
    local file=

    path="$THIS_PROJECT_PATH"
    #path="/d/code-store/mirros/mongo"
    mkdir -p "$path"
    file="$path/Dockerfile"
    echo "gen Dockerfile :$file"
    TXT=$(add_dockerfile)
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT" >"$file"

    file="$path/.dockerignore"
    echo "gen .dockerignore :$file"
    TXT=$(add_dockerignore)
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT" >"$file"

    file="$path/license"
    echo "gen license :$file"
    TXT=$(add_license)
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT" >"$file"

    file="$path/readme.md"
    echo "gen readme.md :$file"
    TXT=$(add_readme)
    #TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT" >"$file"

    file="$path/.gitignore"
    echo "gen .gitignore :$file"
    TXT=$(add_gitignore)
    TXT=$(echo "$TXT" | sed "s/^ *#.*//g" | sed "/^$/d")
    echo "$TXT" >"$file"
}

main_fun

#### usage
#./tool/init.sh

#https://hub.docker.com/_/mongo/
