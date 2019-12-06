# alpine-mongo

## desc

a docker image base on alpine with mongo

## how to use with developer?

### define config
```
cat >tool/hub_list.txt <<EOF
#repo-owner-pass
#hub.docker.com=your user =your pass
registry.cn-hangzhou.aliyuncs.com=xxx=xxx
 EOF
```


```
cat >tool/img_list.txt <<EOF
#name-label=name-label
mongo-alpine-3.8.4=mongo-alpine-3.8.4
mongo-alpine-3.9.4=mongo-alpine-3.9.4
#mongo-alpine-3.10.3=mongo-alpine-3.10.3
 EOF
```


### build image
build the image with your config
```
./tool/build.sh
```

it will build image mongo:alpine-3.8.4 and mongo:alpine-3.9.4 .

the mongo:alpine-3.10.3 will not be build with `#` comment.

### test image
test the image you build
```
./tool/test.sh
```

it will test image mongo:alpine-3.8.4 and mongo:alpine-3.9.4 .

### push image

tag and push the image to some docker hub ,eg. docker hub ,aliyun,qiniu ...
```
img_ns=yemiancheng
./tool/push.sh "$img_ns"
```

it will tag image for docker hub registry.cn-hangzhou.aliyuncs.com ,so there will be:
```
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.8.4
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.9.4
```

the hub.docker.com will not be taged with `#` comment.


it will push image :
```
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.8.4
registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.9.4
```

the hub.docker.com will not be pushed with `#` comment.

so that you need to set pass in tool/hub_list.txt . and for secure dont let other person know it.

## how to use with production ?

### pull image with docker cli
```
tag=registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-X.X.X
docker pull "$tag"
```

### run image with docker cli
```
docker run -d --name mongo -p 3306:3306 -v $(pwd):/app -e mongo_DATABASE=admin -e mongo_USER=huahua -e mongo_PASSWORD=MjAxOS -e mongo_ROOT_PASSWORD=jo1NQo "$tag"
```

note:in the .env file , you can change the different values to suit your needs.

### uses with a dockerfile 
```
FROM registry.cn-hangzhou.aliyuncs.com/yemiancheng/mongo:alpine-3.9.4
```

your can run with docker cli :
```
docker run -v $(pwd)/mongo/data/:/data/db/mongo -d -p 27017:27017 --name mongo-alpine-3.9.4 where/your/dockerfile
```

or your can run with docker-compose ,

or your can run with k8s .

## building log

```
#2019-12-06 17:38:00
ok:mongo-3.4.10-alpine-3.7.3
ok:mongo-3.6.7-alpine-3.8.4
ok:mongo-4.0.5-alpine-3.9.4
```
