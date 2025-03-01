#!/bin/bash

# Obtém o nome do usuário original (quem chamou sudo antes)
USER_ORIGINAL=$(logname)

# Verifica se yay está instalado, se não estiver, instala
if ! command -v yay &>/dev/null; then
  echo "Instalando yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  sudo -u "$USER_ORIGINAL" git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay || exit 1
  sudo -u "$USER_ORIGINAL" makepkg -si --noconfirm
  cd ~ || exit 1
  rm -rf /tmp/yay
else
  echo "yay já está instalado, pulando esta etapa."
fi

# Lista de pacotes do AUR
AUR_PACOTES=(
  hyprshot
  swaync
  hyprpaper
  wofi
  waybar
  hyprlock
)

# Executa a instalação dos pacotes do AUR no usuário original (sem sudo)
echo "Instalando pacotes do AUR com yay..."
sudo -u "$USER_ORIGINAL" yay -Sy --noconfirm --sudoloop "${AUR_PACOTES[@]}"

echo "Instalação via yay concluída!"
