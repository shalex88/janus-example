#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
JANUS_DIR=/opt/janus

install_dependencies() {
    sudo apt update
    sudo apt install libmicrohttpd-dev libjansson-dev \
        libssl-dev libsofia-sip-ua-dev libglib2.0-dev \
        libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
        libconfig-dev pkg-config libtool automake libnice-dev libsrtp2-dev
}

build_janus() {
    git clone https://github.com/meetecho/janus-gateway.git -b v1.2.2
    cd janus-gateway

    sh autogen.sh
    ./configure --prefix=/opt/janus
    make
    sudo make install
    sudo make configs
}

disable_by_default() {
    sudo systemctl stop janus
    sudo systemctl disable janus
}

backup_janus_configs() {
    if [ ! -d /etc/janus.backup ]; then
        sudo cp -r $JANUS_DIR/etc/janus $JANUS_DIR/etc/janus.backup
    fi
}

# Check if Janus is already installed
if ! command -v janus &> /dev/null; then
    # Update system packages
    install_dependencies
    build_janus
    sudo ln -sf $JANUS_DIR/bin/janus /usr/local/bin/janus
    disable_by_default
    backup_janus_configs
fi

# Create symlink to the new config
sudo ln -sf "$SCRIPT_DIR/config/janus.jcfg" $JANUS_DIR/etc/janus/janus.jcfg
sudo ln -sf "$SCRIPT_DIR/config/janus.plugin.streaming.jcfg" $JANUS_DIR/etc/janus/janus.plugin.streaming.jcfg
sudo ln -sf "$SCRIPT_DIR/config/janus.transport.websockets.jcfg" $JANUS_DIR/etc/janus/janus.transport.websockets.jcfg

janus -C $JANUS_DIR/etc/janus/janus.jcfg
