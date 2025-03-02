#!/bin/bash

# Diretório onde os wallpapers serão armazenados
WALLPAPER_DIR="$HOME/.config/backgrounds/"

# Verifica permissões do diretório antes de prosseguir
if [ ! -w "$WALLPAPER_DIR" ]; then
    echo "Sem permissão de escrita em $WALLPAPER_DIR. Tentando corrigir..."
    chmod u+w "$WALLPAPER_DIR" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Não foi possível corrigir permissões. Mudando para $HOME/backgrounds/"
        WALLPAPER_DIR="$HOME/backgrounds/"
        mkdir -p "$WALLPAPER_DIR"
        if [ ! -w "$WALLPAPER_DIR" ]; then
            echo "Erro: Não foi possível criar um diretório com permissão de escrita."
            exit 1
        fi
    fi
else
    mkdir -p "$WALLPAPER_DIR"
fi

# Caminho do arquivo com a chave da API
KEY_FILE="$HOME/.config/scripts/unsplash_key"

# Verifica se o arquivo da chave existe
if [ ! -f "$KEY_FILE" ]; then
    echo "Arquivo da chave ($KEY_FILE) não encontrado."
    exit 1
fi

# Lê a chave do arquivo
UNSPLASH_KEY=$(cat "$KEY_FILE")

# URL do Unsplash para buscar imagens com resolução 1920x1080
UNSPLASH_URL="https://api.unsplash.com/search/photos?query=1920x1080&per_page=10&client_id=$UNSPLASH_KEY"

# Limpa o diretório de wallpapers
rm -rf "$WALLPAPER_DIR"/*

# Faz uma requisição para buscar imagens
RESPONSE=$(curl -s "$UNSPLASH_URL")
if [ $? -ne 0 ]; then
    echo "Erro ao acessar a API do Unsplash."
    exit 1
fi

# Verifica se a resposta contém dados válidos
echo "$RESPONSE" | jq -e '.' >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Resposta inválida da API: $RESPONSE"
    exit 1
fi

# Extrai as URLs das imagens (pega 2 aleatórias dos resultados)
IMAGE_URLS=($(echo "$RESPONSE" | jq -r '.results[] | .urls.full' | shuf -n 2))

# Verifica se obteve 2 URLs
if [ ${#IMAGE_URLS[@]} -ne 2 ]; then
    echo "Não foi possível obter 2 URLs de imagens. Resposta: $RESPONSE"
    exit 1
fi

# Baixa as duas imagens
for i in {0..1}; do
    TEMP_FILE="$WALLPAPER_DIR/wallpaper_$((i+1)).jpg"
    IMAGE_URL="${IMAGE_URLS[$i]}"

    if [ -z "$IMAGE_URL" ]; then
        echo "URL da imagem $((i+1)) está vazia."
        exit 1
    fi

    echo "Tentando baixar imagem $((i+1)) em: $TEMP_FILE"
    echo "URL: $IMAGE_URL"

    # Baixa a imagem com opções verbosity para debug
    curl -L -o "$TEMP_FILE" --retry 3 --retry-delay 2 "$IMAGE_URL" -w "HTTP Status: %{http_code}, Size: %{size_download} bytes\n"
    CURL_EXIT=$?

    # Verifica o resultado
    if [ $CURL_EXIT -ne 0 ] || [ ! -s "$TEMP_FILE" ]; then
        echo "Falha ao baixar a imagem $((i+1))."
        echo "Código de saída do curl: $CURL_EXIT"
        echo "Tamanho do arquivo: $(stat -c %s "$TEMP_FILE" 2>/dev/null || echo 'não existe')"
        curl -L -I "$IMAGE_URL" | grep "HTTP/"
        exit 1
    else
        echo "Imagem $((i+1)) baixada com sucesso: $TEMP_FILE"
        echo "Tamanho: $(stat -c %s "$TEMP_FILE") bytes"
    fi
done

# Detecta os monitores conectados usando xrandr
MONITORS=$(xrandr --query | grep " connected" | cut -d" " -f1)

# Verifica se há monitores detectados
if [ -z "$MONITORS" ]; then
    echo "Nenhum monitor detectado."
    exit 1
fi

# Comando base do feh
FEH_CMD="feh --no-fehbg --bg-scale"

# Lista para armazenar wallpapers
WALLPAPERS=()

# Seleciona os wallpapers baixados para cada monitor
for MONITOR in $MONITORS; do
    WALLPAPER=$(ls "$WALLPAPER_DIR"/*.jpg | shuf -n 1)
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
