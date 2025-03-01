#!/bin/bash

# Diretório de imagens
BG_DIR="$HOME/.config/backgrounds"

# Lista de imagens disponíveis
IMAGES=($(ls "$BG_DIR"/*.png))

# Nomes dos monitores (baseado no hyprctl monitors)
MONITOR1="HDMI-A-2"
MONITOR2="DVI-D-1"

# Escolhe duas imagens aleatórias diferentes
IMAGE1="${IMAGES[$RANDOM % ${#IMAGES[@]}]}"
IMAGE2="${IMAGES[$RANDOM % ${#IMAGES[@]}]}"
while [ "$IMAGE1" == "$IMAGE2" ]; do # Garante que sejam diferentes
    IMAGE2="${IMAGES[$RANDOM % ${#IMAGES[@]}]}"
done

# Caminho do arquivo de configuração
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Reescreve o arquivo de configuração
cat > "$CONFIG_FILE" <<EOL
preload = $IMAGE1
preload = $IMAGE2
wallpaper = $MONITOR1,$IMAGE1
wallpaper = $MONITOR2,$IMAGE2
EOL

# Recarrega o hyprpaper
pkill hyprpaper
hyprpaper &
