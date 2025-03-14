# #!/bin/bash

# # Obtém o volume atual
# VOLUME=$(pamixer --get-volume)

# # Verifica se o som está mutado
# MUTED=$(pamixer --get-mute)

# if [ "$MUTED" == "true" ]; then
#     echo ""  # Ícone para som mutado
# else
#     echo "$VOLUME%"  # Exibe o volume atual
# fi

#!/bin/bash

#!/bin/bash

# Detecta o sink padrão do PulseAudio
SCONTROL=$(pactl get-default-sink)

# Define o passo de alteração do volume
STEP="5%"

# Função para verificar se o áudio está mudo
is_muted() {
    pactl get-sink-mute "$SCONTROL" | awk '{print $2}'
}

# Função para obter o volume atual
get_volume() {
    pactl get-sink-volume "$SCONTROL" | awk '{print $5}' | head -n1
}

# Formata a saída para exibição na Polybar
print_volume() {
    VOL=$(get_volume)
    if [ "$(is_muted)" == "yes" ]; then
        echo ""
    else
        echo "$VOL"
    fi
}

# Captura eventos do mouse
case $1 in
    up) pactl set-sink-volume "$SCONTROL" +$STEP ;;   # Aumenta o volume
    down) pactl set-sink-volume "$SCONTROL" -$STEP ;; # Diminui o volume
    toggle) pactl set-sink-mute "$SCONTROL" toggle ;; # Muta/desmuta
esac

# Exibir volume atual
print_volume
