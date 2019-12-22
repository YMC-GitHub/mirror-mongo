#!/bin/sh

THIS_FILE_PATH=$(
    cd $(dirname $0)
    pwd
)
source $THIS_FILE_PATH/function-list.sh
THIS_PROJECT_PATH=$(path_resolve "$THIS_FILE_PATH" "../")
RUN_SCRIPT_PATH=$(pwd)

function main_func() {
    local list=
    local i=
    local arr=
    local COMMIT_MSG=
    local path=
    cd "$RUN_SCRIPT_PATH"
    list=$(
        cat <<EOF
#readme.md
#tool/build-log.txt
#tool/debug-log.txt
#tool/debug-tmp.txt
#tool/debug.sh
#tool/issues.sh
#tool/test.sh
#tool/init.sh
#Dockerfile
#startup.sh
#conf.d/mongodb.conf
tool/commit.sh
EOF
    )
    #get list
    #2 only on staged
    #git diff --cached --name-only
    #2 on the wokerspace
    #git diff --name-only
    #git status
    list=$(echo "$list" | sed "s/^#.*//g" | sed "/^$/d")
    arr=(${list//,/ })
    for i in ${arr[@]}; do
        echo "git add $i"
        git add "$i"
    done

    COMMIT_MSG=$(
        cat <<EOF
build(tool): initing commit
EOF
    )
    echo "$COMMIT_MSG" >.git/COMMIT_EDITMSG
    git commit --file .git/COMMIT_EDITMSG
    # cat .git/COMMIT_EDITMSG
}
main_func

### file usage
# ./tool/commit.sh
