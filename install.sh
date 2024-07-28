#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install() {
    temp_dir=$(mktemp -d)

    if [ "$ARCH" == "arm64" ]; then
        arch="arm64v8"
    else
        arch=$ARCH
    fi

    file_name="mediamtx_v1.8.3_linux_$arch.tar.gz"
    url="https://github.com/bluenviron/mediamtx/releases/download/v1.8.3/$file_name"
    wget -P "$temp_dir" $url
    mkdir -p $SCRIPT_DIR/mediamtx
    tar -xvf "$temp_dir/$file_name" -C "$SCRIPT_DIR/mediamtx"
    rm -rf "$temp_dir"
}

install_config() {
    cp $SCRIPT_DIR/config/mediamtx.yml $SCRIPT_DIR/mediamtx/mediamtx.yml
}

# Check if Janus is already installed
if [ ! -f "$SCRIPT_DIR/mediamtx/mediamtx" ]; then
    install
    install_config
fi
