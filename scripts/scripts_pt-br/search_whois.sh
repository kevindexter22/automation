#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
# Declarando Variáveis
# ─────────────────────────────────────────────────────────────────────────────

# ──────────────────────
# Cores
# ──────────────────────

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[0;33m'

ORANGE='\033[1;33m'    # Cor próxima ao laranja

MAGENTA='\033[1;35m'

BLUE='\033[0;34m'

GRAY='\033[1;30m'

RESET='\033[0m'


# ────────────────────────────────────────────────────────────────────────────────────────
# Função para consultar IP e Domínio no Whois do Registro.BR e salvar os resultados
# ────────────────────────────────────────────────────────────────────────────────────────
  executar_comando_registroBR() {
      local dir="/home/$USER/Documentos/Scripts/whois/"
      local input_file=$dir"lista_consultar_whois.txt"
      local output_file=$dir"resultados_whois_registro_br.txt"
    
      # Verifica se o arquivo de entrada existe
      if [ ! -f "$input_file" ]; then
          echo "Erro: O arquivo $input_file não foi encontrado!"
          exit 1
      fi

      echo "Salvando os resultados em $output_file..."
      > "$output_file"  # Limpa o arquivo de saída

      # Loop para  cada linha do arquivo de entrada
      while IFS= read -r ip; do
        # Verifica se a linha não está vazia
          if [ -n "$ip" ]; then
              echo "Buscando informações do IP ou domínio $ip..."
              echo "==== Informações do IP ou domínio $ip ====" >> "$output_file"
              whois -h whois.registro.br "$ip" >> "$output_file" 2>&1
              echo "===============================" >> "$output_file"
              echo -e "\n\n" >> "$output_file"
          fi
      done < "$input_file"

      echo "Consulta no Whois do Registro.br concluída! Resultados salvos em $output_file."
  }


# ────────────────────────────────────────────────────────────────────────────────────────
# Função para consultar IP e Domínio no Whois da LACNIC e salvar os resultados
# ────────────────────────────────────────────────────────────────────────────────────────
   executar_comando_lacnic() {
      local dir="/home/$USER/Documentos/Scripts/whois/"
      local input_file=$dir"lista_consultar_whois.txt"  # Arquivo fixo de entrada com IPs ou domínios
      local output_file=$dir"resultados_ip_whois_lacnic.txt"

      # Verifica se o arquivo de entrada existe
      if [ ! -f "$input_file" ]; then
          echo "Erro: O arquivo $input_file não foi encontrado!"
          exit 1
      fi

      echo "Salvando os resultados em $output_file..."
      > "$output_file"  # Limpa o arquivo de saída

      # Loop para cada linha do arquivo de entrada
      while IFS= read -r ip; do
          # Verifica se a linha não está vazia
          if [ -n "$ip" ]; then
              echo "Buscando informações do IP ou domínio $ip..."
              echo "==== Informações do IP ou domínio $ip ====" >> "$output_file"
              whois -h whois.lacnic.net "$ip" >> "$output_file" 2>&1
              echo "===============================" >> "$output_file"
              echo -e "\n\n" >> "$output_file"
          fi
      done < "$input_file"

      echo "Consulta no Whois da LACNIC concluída! Resultados salvos em $output_file."
     }

# ────────────────────────────────────────────────────────────────────────────────────────
# Função para consultar IP e Domínio em ambos os Whois e salvar os resultados
# ────────────────────────────────────────────────────────────────────────────────────────

  executar_comando_whois() {
      local dir="/home/$USER/Documentos/Scripts/whois/"
      local input_file=$dir"lista_consultar_whois.txt"  # Arquivo fixo de entrada com IPs ou domínios
      local output_file=$dir"resultados_ip_whois.txt"

      # Verifica se o arquivo de entrada existe
    if [ ! -f "$input_file" ]; then
        echo "Erro: O arquivo $input_file não foi encontrado!"
        exit 1
    fi

    echo "Salvando os resultados em $output_file..."
    > "$output_file"  # Limpa o arquivo de saída

    # Loop para cada linha do arquivo de entrada
    while IFS= read -r ip; do
        if [ -n "$ip" ]; then
            echo "Buscando informações do IP ou domínio $ip..."
            echo "==== Informações do IP ou domínio $ip ====" >> "$output_file"
            echo >> "$output_file"

            # Tenta no Registro.br
            local resultado_registro_br
            resultado_registro_br=$(whois -h whois.registro.br "$ip" 2>&1)

            # Tenta no LACNIC
            local resultado_lacnic
            resultado_lacnic=$(whois -h whois.lacnic.net "$ip" 2>&1)

            # Adiciona os resultados ao arquivo de saída
            if [ -n "$resultado_registro_br" ] && ! echo "$resultado_registro_br" | grep -q "No match for"; then
                echo "Resultado do Registro.br:" >> "$output_file"
                echo >> "$output_file"
                echo "$resultado_registro_br" >> "$output_file"
                echo >> "$output_file"
                echo "===============================" >> "$output_file"
            fi

            if [ -n "$resultado_lacnic" ] && ! echo "$resultado_lacnic" | grep -q "No match for"; then
                echo >> "$output_file"
                echo "Resultado do LACNIC:" >> "$output_file"
                echo >> "$output_file"
                echo "$resultado_lacnic" >> "$output_file"
                echo >> "$output_file"
                echo "===============================" >> "$output_file"
            fi

            if [ -z "$resultado_registro_br" ] && [ -z "$resultado_lacnic" ]; then
                echo "Nenhuma informação encontrada para $ip." >> "$output_file"
            fi

            echo "===============================" >> "$output_file"
            echo -e "\n" >> "$output_file"
        fi
    done < "$input_file"

    echo "Consulta concluída! Resultados salvos em $output_file."
}

# ─────────────────────────────────────────────────────────────────────────────
# Instruções
# ─────────────────────────────────────────────────────────────────────────────
      como_usar() {
       echo 'Instruções de uso: '
       echo
       echo '1- Adicione os IPs ou domínios a serem consultados no arquivo lista_consultar_whois.txt'
       echo '2- O arquivo lista_consultar_whois.txt se encontra no diretório /home/'$USER'/Documentos/Scripts/whois'
       echo '3- Os arquivos com os resultados da consulta também ficarão armazenados no mesmo diretório'
       echo '4- Caso o diretório não exista você pode cria-lo utilizando o comando mkdir /home/'$USER'/Documentos/Scripts && mkdir /home/'$USER'/Documentos/Scripts/whois'
       echo
  }

# ─────────────────────────────────────────────────────────────────────────────
# Função de mensagem
# ─────────────────────────────────────────────────────────────────────────────

    msg() {
        tput setaf 2
        echo "[*] $1"
        tput sgr0
    }

    error_msg() {
       tput setaf 1
       echo "[!] $1"
       tput sgr0
    }

# ─────────────────────────────────────────────────────────────────────────────
# Mostrar banner e menu
# ─────────────────────────────────────────────────────────────────────────────

    print_banner() {
        echo -e "${GREEN}
        
 ╔════════════════════════════════════════════════════════════════════════╗
 ║          Script de Consulta de Registro de IPs e Domínios              ║
 ║                                                                        ║
 ║                                                                        ║
 ║ Feito por: Kevin Oliveira                                              ║
 ║ Versão do script: 2.0                                                  ║
 ╚════════════════════════════════════════════════════════════════════════╝
    
        ${RESET}"
    }

    show_menu() {
        echo -e "${ORANGE}Selecione o que deseja fazer: ${RESET}"
        echo
        echo '1  - Realizar consulta no Whois do Registro.BR' 
        echo '2  - Realizar consulta no Whois da LACNIC'
        echo '3  - Não sei em qual encontrarei a informação'
        echo 'i  - Instruções para usar esse script'
        echo 's  - Sair'
        echo
    }

# ─────────────────────────────────────────────────────────────────────────────
# Funções para o script executar as tarefas
# ─────────────────────────────────────────────────────────────────────────────

    main() {
       while true; do
         print_banner
         show_menu
         read -p 'Digite sua escolha: ' choice
         case $choice in
         1)  
             executar_comando_registroBR
             msg 'Consulta no Whois do Registro.BR concluída!'
             ;;
         2)
             executar_comando_lacnic
             msg 'Consulta no Whois da LACNIC concluída!'
             ;;
         3)
             executar_comando_whois
             msg 'Consulta no Whois concluída!'
             ;;
         i)
             como_usar
             ;;
         s)
             msg 'Até mais!'
             exit 0
             ;;
         *)
             error_msg 'Opção inválida. Por favor, escolha um número ou "s" para sair.'
         esac
       done
    }
 
(return 2> /dev/null) || main
