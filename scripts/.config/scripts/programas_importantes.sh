#!/bin/bash

# Lista de pacotes para instalar
packages=(
    scrot
    imagemagick
    i3lock
    pv
    samba
    git
    nano
    gvim
    wget
    curl
    openssh
    rofi
    polybar
    bluez
    bluez-utils
    numlockx
    systemd
    galculator
    ethtool
    rsync
    thunar-archive-plugin
    engrampa
)

# Instala os pacotes com pacman
sudo pacman -Sy "${packages[@]}"
