#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

disable_by_default() {
    sudo systemctl stop janus
    sudo systemctl disable janus
}

backup_janus_configs() {
    if [ ! -d /etc/janus.backup ]; then
        sudo cp -r /etc/janus /etc/janus.backup
    fi
}

# Check if Janus is already installed
if ! command -v janus &> /dev/null; then
    # Update system packages
    sudo apt update

    sudo apt install -y janus libwebsockets-dev
fi

disable_by_default
backup_janus_configs

# Create symlink to the new config
sudo ln -sf "$SCRIPT_DIR/config/janus.jcfg" /etc/janus/janus.jcfg
sudo ln -sf "$SCRIPT_DIR/config/janus.plugin.streaming.jcfg" /etc/janus/janus.plugin.streaming.jcfg
sudo ln -sf "$SCRIPT_DIR/config/janus.transport.websockets.jcfg" /etc/janus/janus.transport.websockets.jcfg

janus -C /etc/janus/janus.jcfg
