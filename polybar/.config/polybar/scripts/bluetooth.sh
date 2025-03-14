#!/bin/bash

# Verifica se o bluetooth está ativo
if [ "$(bluetoothctl show | grep 'Powered: yes' | wc -l)" -eq 1 ]; then
    # Verifica se há dispositivo conectado
    connected=$(bluetoothctl info | grep 'Name' | cut -d ' ' -f 2-)
    
    if [ -n "$connected" ]; then
        # Mostra o ícone de bluetooth conectado em #cba6f7 e o nome em #cdd6f4
        echo "%{F#cba6f7}󰂱%{F-} %{F#cdd6f4}$connected%{F-}"
    else
        # Mostra ícone de bluetooth desligado em #cdd6f4 quando não conectado
        echo "%{F#cdd6f4}󰂲%{F-}"
    fi
else
    # Mostra ícone em #f38ba8 (vermelho-rosa) quando bluetooth está desligado
    echo "%{F#f38ba8}󰂲%{F-}"
fi
