#!/bin/bash
echo "Executando script de teclado em $(date)" > ~/keyboard_log.txt

# Forçar o ambiente do X
[ -z "$DISPLAY" ] && export DISPLAY=:0
setxkbmap -layout us -variant intl -option
setxkbmap -query >> ~/keyboard_log.txt
