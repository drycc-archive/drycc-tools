#!/usr/bin/env bash

STACK=${STACK:-heroku-18}
VERSION=${VERSION:-canary}

function echo_title() {
    echo $'\e[1G----->' "$*" | cat -
}

function echo_normal() {
    echo $'\e[1G      ' "$*" | cat -
}

echo_title "The Drycc slug tool"
echo_normal
echo_title "Usage: slug <command> [<args>...]"
echo_normal
echo_normal "slug build <dest_dir>"
echo_normal "slug run <dest_dir> <process_type>"
echo_normal "slug logs"
echo_normal "slug stop"
echo_normal
echo_title "Use stack:$STACK, version: $VERSION"
echo_normal
echo_normal "They are environment variables that you can set through export."
echo_normal
echo_title "For example:"
echo_normal
echo_normal "export STACK=heroku-18"
echo_normal "export VERSION=canary"
echo_normal
echo_title "Running $1 method... but first, a cup of tea!"
echo_normal


build(){
    rm -rf .heroku
    build_dir="/tmp/92b4dce477634b5a9bab53e941f3f73b"
    mkdir -p $build_dir
    docker run --name slugbuilder \
        --rm \
        -v $PWD:/app \
        -v $build_dir:/tmp/build \
        drycc/slugbuilder:$VERSION.$STACK
    mv $build_dir $1
}

run(){
    app_dir=$(cd "$(dirname "$1")";pwd)
    docker run --name slugrunner -d \
        --rm \
        -v $app_dir/$1:/app \
        drycc/slugrunner:$VERSION.$STACK \
        /runner/init start $2 
}

logs(){
    docker logs -f slugrunner
}

stop(){
    docker stop slugrunner
}

$@
