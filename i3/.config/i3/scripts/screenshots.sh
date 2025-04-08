#!/bin/bash

# Caminho de log opcional
LOG="$HOME/.local/share/screenshotkj.log"
mkdir -p "$(dirname "$LOG")"

# Verifica se os comandos estão disponíveis
for cmd in maim copyq notify-send xdotool; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[$(date)] Erro: comando $cmd não encontrado." | tee -a "$LOG"
        notify-send "Erro no Screenshot" "Comando $cmd não encontrado"
        exit 1
    fi
done

# Garante que copyq está rodando
if ! pgrep -x copyq &>/dev/null; then
    copyq & disown
    sleep 0.3
fi

# Função para log e notificação
function notificar() {
    local titulo="$1"
    local msg="$2"
    notify-send "$titulo" "$msg"
    echo "[$(date)] $titulo - $msg" >> "$LOG"
}

# Verifica o modo da captura
case "$1" in
  full)
    maim | copyq copy image/png -
    if [ $? -eq 0 ]; then
        notificar "Screenshot" "Tela inteira capturada!"
    else
        notificar "Erro" "Falha ao capturar tela inteira"
    fi
    ;;

  window)
    WIN_ID=$(xdotool getactivewindow)
    if [ -n "$WIN_ID" ]; then
        maim --window "$WIN_ID" | copyq copy image/png -
        if [ $? -eq 0 ]; then
            notificar "Screenshot" "Janela ativa capturada!"
        else
            notificar "Erro" "Falha ao capturar janela ativa"
        fi
    else
        notificar "Erro" "Nenhuma janela ativa detectada"
    fi
    ;;

  select)
    maim --select | copyq copy image/png -
    if [ $? -eq 0 ]; then
        notificar "Screenshot" "Área selecionada capturada!"
    else
        notificar "Erro" "Falha ao capturar área selecionada"
    fi
    ;;

  *)
    notificar "Screenshot" "Uso: $0 [full|window|select]"
    exit 1
    ;;
esac
