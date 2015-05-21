#!/bin/bash
if [ ! -d "$2" ]; then
    sudo mkdir -p "$2"
fi
sudo cp -R "$1" "$2"
