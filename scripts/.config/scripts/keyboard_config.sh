#!/bin/bash
# Aguarda 2 segundos antes de prosseguir
sleep 2

# Forçar o ambiente do X
#[ -z "$DISPLAY" ] && export DISPLAY=:0
setxkbmap -layout us -variant intl -option
