#!/bin/bash

# Diretório onde estão os wallpapers
WALLPAPER_DIR="$HOME/.config/backgrounds/"

# Detecta os monitores conectados usando xrandr
MONITORS=$(xrandr --query | grep " connected" | cut -d" " -f1)

# Verifica se há monitores detectados
if [ -z "$MONITORS" ]; then
    echo "Nenhum monitor detectado."
    exit 1
fi

# Conta os monitores
MONITOR_COUNT=$(echo "$MONITORS" | wc -l)

# Comando base do feh
FEH_CMD="feh --no-fehbg --bg-scale"

# Lista para armazenar wallpapers
WALLPAPERS=()

# Seleciona um wallpaper aleatório para cada monitor
for MONITOR in $MONITORS; do
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)
    if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
        WALLPAPERS+=("\"$WALLPAPER\"")
    else
        echo "Wallpaper não encontrado ou inválido para $MONITOR"
    fi
done

# Adiciona os wallpapers ao comando
for WP in "${WALLPAPERS[@]}"; do
    FEH_CMD="$FEH_CMD $WP"
done

# Executa o comando completo se houver wallpapers
if [ ${#WALLPAPERS[@]} -gt 0 ]; then
    echo "Executando: $FEH_CMD"
    eval "$FEH_CMD"
else
    echo "Nenhum wallpaper válido para configurar."
    exit 1
fi
