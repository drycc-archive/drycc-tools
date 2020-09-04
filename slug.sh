#!/usr/bin/env bash

STACK=${STACK:-heroku-18}
VERSION=${VERSION:-canary}

function echo_title() {
    echo $'\e[1G----->' "$*" | cat -
}

function echo_normal() {
    echo $'\e[1G      ' "$*" | cat -
}

function usage(){
    echo_title "The Drycc slug tool"
    echo_normal
    echo_title "Usage: slug <command> [<args>...]"
    echo_normal
    echo_normal "slug build <dest_dir> [<docker_options>...]"
    echo_normal "slug run <dest_dir> <process_type> [<docker_options>...]"
    echo_normal "slug logs <docker_options>"
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
    echo_title "Enjoy life, enjoy time!!!"
    echo_normal
}


build(){
    build_dir="/tmp/92b4dce477634b5a9bab53e941f3f73b"
    if [[ -d ".heroku" ]]; then
        echo -e "\033[31mThe .heroku directory exists in the current project.\033[0m"
        echo -e "\033[31mPlease delete or rename it first.\033[0m"
        exit 1
    fi
    if [[ -d "$1" ]]; then
        echo -e "\033[31mThe $1 directory already exists.\033[0m"
        echo -e "\033[31mPlease delete it first.\033[0m"
        exit 1
    fi
    size=${#@}
    rm -rf $build_dir
    mkdir -p $build_dir
    docker run --name slugbuilder \
        --rm \
        -v $PWD:/app \
        -v $build_dir:/tmp/build \
        ${@:2:size+1} \
        drycc/slugbuilder:$VERSION.$STACK
    mv $build_dir $1
}

run(){
    size=${#@}
    dest_dir=$(cd "$(dirname "$1")";pwd)/$1
    docker run --name slugrunner \
        --rm \
        -v $dest_dir:/app \
        ${@:3:size+1} \
        drycc/slugrunner:$VERSION.$STACK \
        /runner/init start $2 
}

logs(){
    docker logs $@ slugrunner
}

stop(){
    docker stop slugrunner
}

$@


if [ $? -ne 0 ]; then
    usage
fi
