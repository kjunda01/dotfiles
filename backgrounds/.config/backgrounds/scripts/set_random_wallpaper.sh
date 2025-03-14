#!/bin/bash

# Aguarda 5 segundos antes de prosseguir
#sleep 5 &

# Diretório onde os wallpapers estão armazenados
WALLPAPER_DIR="$HOME/.config/backgrounds/"

# Garante que o diretório existe
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Diretório $WALLPAPER_DIR não encontrado."
    exit 1
fi

# Busca arquivos .jpg no diretório
mapfile -t WALLPAPER_FILES < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "*.jpg")
if [ ${#WALLPAPER_FILES[@]} -eq 0 ]; then
    echo "Nenhum arquivo .jpg encontrado em $WALLPAPER_DIR"
    exit 1
fi

# Verifica se há pelo menos 2 arquivos
if [ ${#WALLPAPER_FILES[@]} -lt 2 ]; then
    echo "Menos de 2 arquivos .jpg encontrados em $WALLPAPER_DIR"
    exit 1
fi

# Seleciona aleatoriamente 2 imagens
SELECTED_WALLPAPERS=($(printf '%s\n' "${WALLPAPER_FILES[@]}" | shuf -n 2))

# Monta o comando do feh com --bg-fill
FEH_CMD="feh --no-fehbg --bg-fill"

# Adiciona as duas imagens selecionadas ao comando
for WP in "${SELECTED_WALLPAPERS[@]}"; do
    if [ -f "$WP" ]; then
        FEH_CMD="$FEH_CMD \"$WP\""
    else
        echo "Erro: Arquivo $WP não encontrado."
        exit 1
    fi
done

# Executa o comando
echo "Executando: $FEH_CMD"
eval "$FEH_CMD"
