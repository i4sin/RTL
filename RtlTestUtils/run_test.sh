#!/usr/bin/env bash
set -e

main() {
    trap remove_docker EXIT

    xhost +local:docker

    CONTAINER_ID=$(docker run --mac-address "00:0c:29:31:ad:65" \
        -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
        -p 10022:22 \
        --detach \
        -v /home/yasin/Projects/RTL/:/Projects/RTL \
        questasim-10.7c-automation:0.1.0)

    docker exec $CONTAINER_ID /bin/bash -c "echo export DISPLAY=$DISPLAY >> /root/.profile"

    if [ -z "$TB_NAME" ]; then
        docker exec $CONTAINER_ID /bin/bash -c "cd Projects/RTL && fusesoc run --target=test $TEST_NAME"
    else
        docker exec $CONTAINER_ID /bin/bash -c "cd Projects/RTL && fusesoc run --target=test $TEST_NAME --vunit_options $TB_NAME"
    fi
}

help() {
    echo "Run like this: ./run_test.sh -i TEST_NAME -t TB_NAME"
}

remove_docker() {
    docker stop $CONTAINER_ID
    docker rm $CONTAINER_ID
}

while getopts ":i:t:h:" opt; do
    case ${opt} in
        i)
            TEST_NAME=$OPTARG
            ;;
        t)
            TB_NAME=$OPTARG
            ;;
        h)
            help
            ;;
        \?)
            help
            ;;
    esac
done

main
