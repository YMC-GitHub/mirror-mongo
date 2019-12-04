#!/bin/sh

THIS_FILE_PATH=$(
    cd $(dirname $0)
    pwd
)
source $THIS_FILE_PATH/function-list.sh
THIS_PROJECT_PATH=$(path_resolve "$THIS_FILE_PATH" "../")
RUN_SCRIPT_PATH=$(pwd)

function get_tag() {
    local tag=
    local ns=
    local name=
    local label=
    local domain=
    domain=reg.qiniu.com
    ns=yemiancheng
    name=mongo
    label=alpine
    if [ -n "${1}" ]; then
        domain="${1}"
    fi
    if [ -n "${2}" ]; then
        ns="${2}"
    fi
    if [ -n "${3}" ]; then
        name="${3}"
    fi
    if [ -n "${4}" ]; then
        label="${4}"
    fi
    tag="$domain/$ns/$name:$label"
    echo "$tag"
}
### func-usage
# get_tag
# get_tag "" "" "" ""
# get_tag "" "" "" ""

function get_image_id() {
    local name=
    local label=
    local id=
    name=mongo
    label=alpine
    if [ -n "${1}" ]; then
        name="${1}"
    fi
    if [ -n "${2}" ]; then
        label="${2}"
    fi
    id="$name:$label"
    echo "$id"
}
### func-usage
# get_image_id
# get_image_id "" ""
function hub_list_to_dic() {
    local list=
    local arr=
    local i=
    local key=
    local val=
    list="$hub_list"
    list=$(echo "$list" | sed "s/^#.*//g" | sed "/^$/d")
    arr=(${list//,/ })
    for i in ${arr[@]}; do
        key=$(echo $i | awk -F'=' '{print $1}')
        hub_list_dic+=([$key]=$i)
    done
}
function parse_hub_list_val() {
    local val="repo=owner=pass"
    if [ -n "${1}" ]; then
        val="${1}"
    fi
    repo=$(echo $val | awk -F'=' '{print $1}')
    owner=$(echo $val | awk -F'=' '{print $2}')
    pass=$(echo $val | awk -F'=' '{print $3}')
    #echo "$val"
    echo "$repo $owner $pass"
}
### func-usage
# parse_hub_list_val

function traver_hub_list() {
    local i=
    local key=
    local val=
    #echo "${!hub_list_dic[*]}"
    #echo "${hub_list_dic[*]}"
    for i in ${!hub_list_dic[*]}; do
        val=${hub_list_dic[$i]}
        parse_hub_list_val "$val"
    done
}
### func-usage
# run this after hub_list_to_dic
# traver_hub_list

function init_hub_list_dic() {
    local key=
    local val=
    key=repo
    val="repo=owner=pass"
    hub_list_dic+=([$key]=$val)
}
### func-usage
# init_hub_list_dic

function get_hub_by_key() {
    local key=
    local val=
    key=repo
    if [ -n "${1}" ]; then
        key="${1}"
    fi
    val="${hub_list_dic[$key]}"
    echo "$val"
}
### func-usage
# run this after hub_list_to_dic
# get_hub_by_key "repo"

function push_one() {
    local hub=
    local img=
    local tag=
    #local name=
    #local label=
    local temp=
    local id=

    hub=registry.cn-hangzhou.aliyuncs.com
    img=alpine-3.9.4
    if [ -n "${1}" ]; then
        hub="${1}"
    fi
    if [ -n "${2}" ]; then
        img="${2}"
    fi
    echo "get repo msg ..."
    parse_hub_list_val $(get_hub_by_key "$hub")
    echo "gen tag for repo ..."
    parse_img_list_val $(get_img_by_key "$img")
    tag=$(get_tag "$repo" "$img_ns" "$name" "$label")
    #echo "$tag"
    id=$(get_image_id "$name" "$label")

    #下拉
    #echo "pull image  $id..."
    #docker pull "$id"

    #构建
    echo "build image  $id..."
    #docker build --tag "$id" "$THIS_PROJECT_PATH"

    #打标
    echo "tag image $id to $tag ..."
    docker tag "$id" "$tag"

    #登录
    echo "docker login --username=\"$owner\" --password=\"$pass\" \"$repo\""
    docker login --username="$owner" --password="$pass" "$repo" >/dev/null 2>&1
    #推送
    echo "push image $tag ..."
    docker push "$tag"
}
### func-usage
# push_one
# push_one "registry.cn-hangzhou.aliyuncs.com" "alpine-3.9.4"
# push_one "" "alpine-3.9.4"

function img_list_to_dic() {
    local list=
    local arr=
    local i=
    local key=
    local val=
    list="$img_list"
    list=$(echo "$list" | sed "s/^#.*//g" | sed "/^$/d")
    arr=(${list//,/ })
    for i in ${arr[@]}; do
        key=$(echo $i | awk -F'=' '{print $1}')
        val=$(echo $i | awk -F'=' '{print $2}')
        img_list_dic+=([$key]=$val)
    done
}
function get_img_by_key() {
    local key=
    local val=
    key=alpine
    if [ -n "${1}" ]; then
        key="${1}"
    fi
    val="${img_list_dic[$key]}"
    echo "$val"
}
function parse_img_list_val() {
    local val="alpine-3.7.4"
    if [ -n "${1}" ]; then
        val="${1}"
    fi
    echo "$val"
    name=$(echo $val | awk -F'-' '{print $1}')
    #label=$(echo $val | awk -F'-' '{print $2}')
    length=$(echo "$val" | awk '{print length($0)}')
    index=$(awk -v a="$val" -v b="-" 'BEGIN{print index(a,b)}')
    label=$(echo $val | cut -b $index-$length | sed "s/^-//g")
    #echo "$length,$index,$label"
    echo "name=$name label=$label"
}
function init_img_list_dic() {
    local key=
    local val=
    key="alpine-3.7.4"
    val="alpine-3.7.4=alpine-3.7.4"
    img_list_dic+=([$key]=$val)
}

function traver_img_list() {
    local i=
    local key=
    local val=
    for i in ${!img_list_dic[*]}; do
        val=${img_list_dic[$i]}
        parse_img_list_val "$val"
    done
}
function push_all_image_to() {
    local i=
    local key=
    local val=
    local hub=""
    if [ -n "${1}" ]; then
        hub="${1}"
    fi
    for i in ${!img_list_dic[*]}; do
        val=${img_list_dic[$i]}
        #push_one "" "alpine-3.9.4"
        echo "push_one\"$hub\" \"$val\""
        push_one "$hub" "$val"
    done
}
function push_to_hub() {
    local i=
    local key=
    local val=
    for i in ${!hub_list_dic[*]}; do
        push_all_image_to "$i"
    done
}

function main_fun() {
    push_to_hub
}

declare -A hub_list_dic
hub_list_dic=()
declare -A img_list_dic
img_list_dic=()

hub_list=$(cat $THIS_FILE_PATH/hub_list.txt)
img_list=$(cat $THIS_FILE_PATH/img_list.txt)
name=
label=
id=
img_ns=yemiancheng
if [ -n "${1}" ]; then
    img_ns="${1}"
fi

#init_hub_list_dic
#get_hub_by_key
#parse_hub_list_val $(get_hub_by_key)
hub_list_to_dic
#traver_hub_list
img_list_to_dic
#traver_img_list
#push_one "" "alpine-3.9.4"
main_fun

### file-usage
# ./tool/push.sh
# ./tool/push.sh "yemiancheng"
