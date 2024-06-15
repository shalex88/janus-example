#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

disable_by_default() {
    sudo systemctl stop janus
    sudo systemctl disable janus
}

install() {
    sudo apt install janus libwebsockets-dev
}

clone_and_build() {
    # Clone Janus repository
    git clone https://github.com/meetecho/janus-gateway.git
    cd janus-gateway

    # Install dependencies
    sudo apt install libmicrohttpd-dev libjansson-dev \
	    libssl-dev libsofia-sip-ua-dev libglib2.0-dev \
	    libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
	    libconfig-dev pkg-config libtool automake

    # Build Janus
    sh autogen.sh
    ./configure --prefix=/usr/bin --enable-websockets --enable-plugin-streaming
    make
    sudo make install
    sudo make configs
}

# Check if Janus is already installed
if ! command -v janus &> /dev/null; then
    # Update system packages
    sudo apt update

    # Choose installation method
    # install
    clone_and_build
fi

disable_by_default()

# Configure Janus Gateway
if [ ! -f /etc/janus/janus.jcfg.backup ]; then
    sudo cp /etc/janus/janus.jcfg /etc/janus/janus.jcfg.backup
fi

if [ ! -f /etc/janus/janus.plugin.streaming.jcfg.backup ]; then
    sudo cp /etc/janus/janus.plugin.streaming.jcfg /etc/janus/janus.plugin.streaming.jcfg.backup
fi

if [ ! -f /etc/janus/janus.transport.websockets.jcfg ]; then
    sudo cp /etc/janus/janus.transport.websockets.jcfg /etc/janus/janus.transport.websockets.jcfg.backup
fi

if [ ! -f /etc/janus/janus.transport.mqtt.jcfg ]; then
    sudo cp /etc/janus/janus.transport.mqtt.jcfg /etc/janus/janus.transport.mqtt.jcfg.backup
fi

# Create symlink to the new config
sudo ln -sf "$SCRIPT_DIR/config/janus.plugin.streaming.jcfg" /etc/janus/janus.plugin.streaming.jcfg
sudo ln -sf "$SCRIPT_DIR/config/janus.jcfg" /etc/janus/janus.jcfg
sudo ln -sf "$SCRIPT_DIR/config/janus.transport.websockets.jcfg" /etc/janus/janus.transport.websockets.jcfg
sudo ln -sf "$SCRIPT_DIR/config/janus.transport.mqtt.jcfg" /etc/janus/janus.transport.mqtt.jcfg

janus