#!/bin/sh

### file-usage
#./tool/debug.sh

THIS_FILE_PATH=$(
    cd $(dirname $0)
    pwd
)
source $THIS_FILE_PATH/function-list.sh
THIS_PROJECT_PATH=$(path_resolve "$THIS_FILE_PATH" "../")
RUN_SCRIPT_PATH=$(pwd)
logfile=$THIS_PROJECT_PATH/tool/debug-log.txt
tpmfile=$THIS_PROJECT_PATH/tool/debug-tmp.txt

VM_MOUNT_PATH=/data/db/mongo
CM_MOUNT_PATH=/data/db/mongo
CM_EXPOSE_PORT="27017"
VM_EXPOSE_PORT="27017"

function parse_img_name_label() {
    local val=
    local length=
    local index=
    val="mongo-alpine-3.9.4"
    if [ -n "${1}" ]; then
        val="${1}"
    fi
    #echo "$val"
    name=$(echo $val | awk -F'-' '{print $1}')
    #label=$(echo $val | awk -F'-' '{print $2}')
    length=$(echo "$val" | awk '{print length($0)}')
    index=$(awk -v a="$val" -v b="-" 'BEGIN{print index(a,b)}')
    label=$(echo $val | cut -b $index-$length | sed "s/^-//g")
    #echo "$length,$index,$label"
    echo "name=$name label=$label"
}
function debug_image() {
    local list=
    list=$(cat $THIS_PROJECT_PATH/tool/img_list.txt)
    list=$(echo "$list" | sed "s/^#.*//g" | sed "/^$/d")
    local temp=
    for val in $list; do
        val=$(echo $val | awk -F'=' '{print $2}')
        parse_img_name_label "$val"
        echo "debug image $name:$label"
        docker container ls --all | grep "$name-$label" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            docker container rm --force --volumes $name-$label
        fi

        #run image with:
        echo "run image ..."
        echo "you can ru image by hands with:"
        echo "docker run -v \"$VM_MOUNT_PATH\":\"$CM_MOUNT_PATH\" -d -p \"$VM_EXPOSE_PORT\":\"$CM_EXPOSE_PORT\" --name $name-$label $name:$label"
        docker run -v "$VM_MOUNT_PATH":"$CM_MOUNT_PATH" -d -p "$VM_EXPOSE_PORT":"$CM_EXPOSE_PORT" --name $name-$label $name:$label
        sleep 30
        #see cm logs with:
        echo "get cm log ..."
        docker container logs $name-$label >/dev/null >$tpmfile 2>&1
        ver=$(cat $tpmfile | grep "db version" | sed "s/db version v//")
        if [ $? -eq 0 ]; then
            info="$name-$ver-$label"
            echo $info
            echo $info >>$logfile
        fi
        ver=$(cat $tpmfile | grep "Password: " | sed "s/.*Password: //")
        if [ $? -eq 0 ]; then echo "mongo root Password: $ver"; fi
        echo "you can see cm logs with:"
        echo "docker container logs $name-$label"
        #go into cm with:
        #docker exec -it $name-$label /bin/sh
        #exit cm with:
        #exit
        #stop cm with:
        echo "stop cm ..."
        docker container stop $name-$label
        echo "delete cm ..."
        #delete cm with:
        docker container rm --force --volumes $name-$label
    done
}

debug_image
