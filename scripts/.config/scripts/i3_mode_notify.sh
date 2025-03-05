#!/bin/bash

# Caminho para o arquivo temporário que a Polybar vai ler
STATE_FILE="/tmp/i3_current_mode"

if [ "$1" == "resize" ]; then
    echo "%{F#ffffff}%{B#ff0000} Resize %{B-}%{F-}" > "$STATE_FILE"
else
    echo "" > "$STATE_FILE"
fi

# Força a Polybar a atualizar
#pkill -USR1 polybar
