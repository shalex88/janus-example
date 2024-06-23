#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install() {
    temp_dir=$(mktemp -d)
    wget -P "$temp_dir" https://github.com/bluenviron/mediamtx/releases/download/v1.8.3/mediamtx_v1.8.3_linux_arm64v8.tar.gz
    mkdir -p ./mediamtx
    tar -xvf "$temp_dir/mediamtx_v1.8.3_linux_arm64v8.tar.gz" -C "./mediamtx"
    rm -rf "$temp_dir"
}

install_config() {
    cp $SCRIPT_DIR/config/mediamtx.yml $SCRIPT_DIR/mediamtx/mediamtx.yml
}

# Check if Janus is already installed
if [ ! -f "mediamtx/mediamtx" ]; then
    install
fi

install_config

$SCRIPT_DIR/mediamtx/mediamtx $SCRIPT_DIR/mediamtx/mediamtx.yml
