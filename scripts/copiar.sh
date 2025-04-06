#!/bin/bash

copiar() {
    if [ $# -ne 2 ]; then
        echo "Uso: copiar <origem> <destino>"
        return 1
    fi

    local origem="$1"
    local destino="$2"

    if [ ! -d "$origem" ]; then
        echo "Erro: O diretório de origem '$origem' não existe"
        return 1
    fi

    mkdir -p "$destino"

    mapfile -t files_array < <(cd "$origem" && find . -type f -print | sed 's|^\./||')
    echo "DEBUG: ${#files_array[@]} arquivos encontrados em $origem"

    local total_files=${#files_array[@]}
    echo -n "Itens ($total_files) "

    local max_length=$(tput cols)
    local line_length=14

    for file in "${files_array[@]}"; do
        name="$(basename "$file")"
        if [[ "$name" == *.* ]]; then
            base="${name%.*}"
            ext="${name##*.}"
            colored_file="${base}.\e[90m${ext}\e[0m"
        else
            colored_file="$name"
        fi

        local visible_length=${#name}
        if [ $((line_length + visible_length + 1)) -gt $max_length ]; then
            echo ""
            echo -n "              "
            line_length=14
        fi
        echo -ne "$colored_file "
        line_length=$((line_length + visible_length + 1))
    done

    echo ""

    local total_bytes=$(du -sb "$origem" | awk '{print $1}')
    local total_mib=$(awk "BEGIN { printf \"%.2f\", $total_bytes / 1024 / 1024 }")
    echo -en "$(tput bold)Tamanho total da cópia:$(tput sgr0)\n"
    echo "${total_mib} MiB"

    echo -ne "$(tput bold):: Proceder com a cópia? [Y/n]$(tput sgr0) "
    read -r resposta
    if [[ "$resposta" =~ ^[Nn]$ ]]; then
        echo "Cópia cancelada pelo usuário."
        return 0
    fi

    local count=1
    local bar_size=72
    local sample_right=$(printf "%7sMiB  %9sMiB/s  %5s [%-*s] %3s%%%%" \
        "9999.9" "9999.9" "99:99" "$bar_size" "$(printf '#%.0s' $(seq 1 $bar_size))" "100")
    local right_width=$(( ${#sample_right} - 7 ))  # Ajuste fino com margem


    local total_cols=$(tput cols)
    local max_filename_width=$((total_cols - right_width - 16))
    local visible_lines=$(( $(tput lines) - 1 ))
    local print_limit=$((visible_lines - 1))

    tput civis
    trap 'tput cnorm; exit' INT TERM

    local completed=0
    local -a lines
    local total_elapsed=0

    for i in "${!files_array[@]}"; do
        lines[$i]=""
    done

    for i in "${!files_array[@]}"; do
        file="${files_array[$i]}"
        local src="$origem/$file"
        local dst="$destino/$file"

        mkdir -p "$(dirname "$dst")" || { echo "Erro ao criar diretório destino para $dst"; continue; }
        local size_bytes=$(stat -c%s "$src")

        name="$(basename "$file")"
        if [[ "$name" == *.* ]]; then
            base="${name%.*}"
            ext="${name##*.}"
            file_display="${base}.${ext}"
        else
            file_display="$name"
        fi

        if [ ${#file_display} -gt $max_filename_width ]; then
            file_display="...${file_display: -$((max_filename_width - 3))}"
        fi

        local start_time=$(date +%s.%N)
        dd if="$src" of="$dst" bs=1M status=none conv=fsync
        sync
        local end_time=$(date +%s.%N)

        local elapsed=$(echo "$end_time - $start_time" | bc -l)
        if (( $(echo "$elapsed < 0.1" | bc -l) )); then
            elapsed=0.1
        fi
        total_elapsed=$(echo "$total_elapsed + $elapsed" | bc -l)

        local elapsed_formatted=$(printf "%02d:%02d" $(echo "$elapsed" | awk '{ sec=int($1); printf "%d %d", sec/60, sec%60 }'))
        local size_mib=$(awk "BEGIN { printf \"%.1f\", $size_bytes / 1024 / 1024 }")
        # local speed_bytes=$(echo "$size_bytes / $elapsed" | bc -l)
        # local speed_mib=$(awk "BEGIN { printf \"%.1f\", $speed_bytes / 1024 / 1024 }")
        local speed_bytes=$(echo "scale=10; $size_bytes / $elapsed" | bc -l)
        # local speed_mib=$(awk "BEGIN { printf \"%.1f\", $speed_bytes / 1024 / 1024 }")
        local speed_mib=$(awk "BEGIN { printf \"%.1f\", $size_bytes / $elapsed / 1024 / 1024 / 10 }")




        local bar=$(printf '#%.0s' $(seq 1 $bar_size))

        local prefix=$(printf "(%3d/%3d) %-*s" "$count" "$total_files" "$max_filename_width" "$file_display")
        local right_info=$(printf "%7sMiB  %9sMiB/s  %5s [%-*s] %3s%%" \
            "$size_mib" "$speed_mib" "$elapsed_formatted" \
            "$bar_size" "$bar" "100")

        local full_line="$prefix$right_info"
        lines[$i]="$full_line"
        count=$((count + 1))
        completed=$((completed + 1))

        clear
        local start_index=$(( completed > print_limit ? completed - print_limit : 0 ))
        for ((j=start_index; j<completed; j++)); do
            printf "%-${total_cols}s\n" "${lines[$j]}"
        done

        local pct_total=$(( completed * 100 / total_files ))
        local bar_done=$(( bar_size * pct_total / 100 ))
        local bar_remaining=$(( bar_size - bar_done ))
        local bar_total="$(printf '#%.0s' $(seq 1 $bar_done))$(printf '.%.0s' $(seq 1 $bar_remaining))"

        local avg_speed_mib=$(awk "BEGIN { printf \"%.1f\", $total_bytes / $total_elapsed / 1024 / 1024 }")
        local total_time_formatted=$(printf "%02d:%02d" $(echo "$total_elapsed" | awk '{ sec=int($1); printf "%d %d", sec/60, sec%60 }'))

        local summary_prefix=$(printf "(%3d/%3d) %-*s" "$completed" "$total_files" "$max_filename_width" "TOTAL")
        local summary_right=$(printf "%7sMiB  %9sMiB/s  %5s [%-*s] %3s%%" \
            "$total_mib" "$avg_speed_mib" "$total_time_formatted" \
            "$bar_size" "$bar_total" "$pct_total")

        local total_line="$summary_prefix$summary_right"
        printf "%s\n" "$total_line"
    done

    printf "\nCópia concluída com sucesso!\n"
    tput cnorm
}