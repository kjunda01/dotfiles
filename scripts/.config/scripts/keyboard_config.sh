#!/bin/bash
# Aguarda 5 segundos antes de prosseguir
sleep 5 &

# Forçar o ambiente do X
[ -z "$DISPLAY" ] && export DISPLAY=:0
setxkbmap -layout us -variant intl -option
setxkbmap -query >> ~/keyboard_log.txt
