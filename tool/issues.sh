#!/bin/sh

function get_issue_txt() {
    local txt=
    txt=$(
        cat <<EOF

$title
## desc

$des

## expected 

\`\`\`
$exp
\`\`\`

## actual

\`\`\`
$err
\`\`\`

## behavior

\`\`\`
$cmd
\`\`\`

## my env

\`\`\`
$env
\`\`\`

## find some thing: 

\`\`\`
$rea
\`\`\`

## how to solve: 

\`\`\`
$sol
\`\`\`

EOF
    )
    echo "$txt"
}

title=$(
    cat <<EOF
get err when test image in vm
EOF
)

# 其描述
des=$(
    cat <<EOF
get err when test image in vm
EOF
)

# 期望值
exp=
# 实际值
err=
err=$(
    cat <<EOF
standard_init_linux.go:211: exec user process caused "permission denied"
EOF
)
# 何行为
cmd=./tool/test.sh

# 何环境
env=$(
    cat <<EOF
PM:WIN10
VM:CENTOS 7.7
CM:APLINE 3.9.4
note:win+virtual+sharedire
EOF
)
# 查原因
rea=$(
    cat <<EOF
docker run -v "/data/db/mongo":"/data/db/mongo" -it -p "27017":"27017" --name mongo-alpine-3.7.3 mongo:alpine-3.7.3 /bin/sh
docker container rm -f mongo-alpine-3.7.3
ls
pwd
ls -l /
#> -rwxrwx---    1 root     root           323 Dec  4 14:22 startup.sh
ps
whoami
chown -R mongo:mongo /startup.sh
EOF
)
txt=$(get_issue_txt)
echo "$txt"

# 期望值
exp=
# 实际值
err=$(
    cat <<EOF
docker: Error response from daemon: OCI runtime create failed: container_linux.go:346: starting container process caused "exec: \"./startup.sh\": stat ./startup.sh: no such file or directory": unknown.
EOF
)
# 何行为
cmd=./tool/test.sh

# 查问题
rea=$(
    cat <<EOF
docker run -v "/data/db/mongo":"/data/db/mongo" -it -p "27017":"27017" --name mongo-alpine-3.7.3 mongo:alpine-3.7.3 /bin/sh
docker container rm -f mongo-alpine-3.7.3
ls
pwd
ls -l /
EOF
)
txt=$(get_issue_txt)
echo "$txt"

# 期望值
exp=
# 实际值
err=$(
    cat <<EOF
/bin/sh: can't open '/startup.sh'
EOF
)
# 何行为
cmd=$(
    cat <<EOF
docker run -v "/data/db/mongo":"/data/db/mongo" -it -p "27017":"27017" --name mongo-alpine-3.7.3 mongo:alpine-3.7.3 /bin/sh
/startup.sh
EOF
)

# 查原因
rea=$(
    cat <<EOF
docker run -v "/data/db/mongo":"/data/db/mongo" -it -p "27017":"27017" --name mongo-alpine-3.7.3 mongo:alpine-3.7.3 /bin/sh
ls -l /
#>-rwxrwx--x    1 root     root           323 Dec  4 14:22 startup.sh
EOF
)

txt=$(get_issue_txt)
echo "$txt"

# 期望值
exp=
# 实际值
err=$(
    cat <<EOF
[initandlisten] User Assertion: 20:Attempted to create a lock file on a read-only directory: /data/db/mongo 
EOF
)
# 何行为
cmd=$(
    cat <<EOF
docker run -v "/data/db/mongo":"/data/db/mongo" -it -p "27017":"27017" --name mongo-alpine-3.7.3 mongo:alpine-3.7.3 /bin/sh
/startup.sh
EOF
)

# 查原因
rea=$(
    cat <<EOF
ls -ld /data/db/mongo
#> drwxr-xr-x    2 root     root             6 Dec  4 06:22 /data/db/mongo
ps
whoami
#>mongo
EOF
)

# 解问题
sol=$(
    cat <<EOF
#case01
#but i can not do it as below in win+virtual+sharedir:
#chown -R mongo:mongo /data/db/mongo

#case02
#it is equal use as a root user
chmod +rwx -R /data/db/mongo
#but i can not do it as below in win+virtual+sharedir

#case03
#have to use the root user to run
EOF
)
txt=$(get_issue_txt)
echo "$txt"

# 期望值
exp=
# 实际值
err=$(
    cat <<EOF
adduser: user 'root' in use
EOF
)
# 何行为
cmd=$(
    cat <<EOF
./tool/build
EOF
)

txt=$(get_issue_txt)
echo "$txt"
