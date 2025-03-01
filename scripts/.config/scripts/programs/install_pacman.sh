#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script como root (use sudo)."
  exit 1
fi

# Obtém o nome do usuário que executou o sudo
USER_ORIGINAL=$(logname)

# Atualiza a base de pacotes do sistema
echo "Atualizando pacotes..."
pacman -Syu --noconfirm

# Lista de pacotes oficiais do repositório do Arch
PACOTES=(
  docker
  docker-compose
  git
  curl
  wget
  openssh
  base-devel
  nautilus
  kitty
)

# Instala pacotes via pacman, verificando antes se já estão instalados
echo "Instalando pacotes via pacman..."
for pkg in "${PACOTES[@]}"; do
  if ! pacman -Qq $pkg &>/dev/null; then
    pacman -S --noconfirm $pkg
  else
    echo "$pkg já está instalado, pulando..."
  fi
done

# Inicia e habilita Docker
echo "Configurando Docker..."
systemctl enable --now docker
usermod -aG docker "$USER_ORIGINAL"

echo "Instalação via pacman concluída!"
