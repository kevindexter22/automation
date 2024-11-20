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

ORANGE='\033[1;33m'    # Próximo ao laranja

MAGENTA='\033[1;35m'

BLUE='\033[0;34m'

GRAY='\033[1;30m'

RESET='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
# Função para extrair IPs (tanto v4 como v6) do PDF
# ─────────────────────────────────────────────────────────────────────────────
  extract_ips_pdf() {
    local file_pdf="$1"
    local file_txt="extracted_ip.txt"

    # Check if PDF exist
    if [ ! -f "$file_pdf" ]; then
       echo "The file $file_pdf don't found!"
       exit 1
    fi

    echo "Found IPs on file $file_pdf:" > /home/$USER/Documentos/Scripts/PDF/"$file_txt" 

    # Convert PDF file to image .png
    pdftoppm "$file_pdf" temp_page -png
    for img in temp_page-*.png; do
       echo "Generating image: $img"

    # Using Tresseract OCR to extract image
    tesseract "$img" temp_text -c preserve_interword_spaces=1

    # check if Tesseract created the text file
    if [ -f temp_text.txt ]; then
            # Extract IPv4 and IPv6 to file txt 
            grep -oP '\b(?:\d{1,3}\.){3}\d{1,3}\b' temp_text.txt >> /home/$USER/Documentos/Scripts/PDF/"$file_txt"  # IPv4
            grep -oP '\b([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\b' temp_text.txt >> /home/$USER/Documentos/Scripts/PDF/"$file_txt"  # IPv6
            # Delete the temp file
            rm temp_text.txt
        fi
        
     # Detele a temp image
     rm "$img"
   
   done
 }
   
# ─────────────────────────────────────────────────────────────────────────────
# Função para melhorar a qualidade do PDF e extrair o conteúdo em modo texto
# ─────────────────────────────────────────────────────────────────────────────
  better_quality_pdf() {
    local file_pdf="$1"
    local output_dir="/home/$USER/Documentos/Scripts/PDF/Otimizados"
    local optimized_pdf="pdf_otimizado.pdf"

    # Check if the file exist
    if [ ! -f "$file_pdf" ]; then
        echo "O arquivo $file_pdf não foi encontrado!"
        exit 1
    fi

    # Create output dir if necessary
    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir"
    fi

    # Optimize PDF
    echo "Otimizando PDF para uma qualidade melhor..."
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$output_dir/$optimized_pdf" "$file_pdf"

    # Check if optimized file was created
    if pdfinfo "$output_dir/$optimized_pdf" > /dev/null 2>&1; then
        echo "PDF otimizado foi salvo em $output_dir/$optimized_pdf"
    else
        echo "Erro ao criar o arquivo otimizado!"
        exit 1
    fi
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
# Função para carregar o PDF
# ─────────────────────────────────────────────────────────────────────────────

  extract_ips() {
      echo "Favor digitar o nome do arquivo: "
      read file_pdf
      msg 'Extraindo IPs encontrados no arquivo...'
      extract_ips_pdf /home/$USER/Documentos/Scripts/PDF/"$file_pdf"
  }

  better_pdf() {
      echo "Favor digitar o nome do arquivo: "
      read file_pdf
      msg 'Otimizando o arquivo PDF...'
      better_quality_pdf /home/$USER/Documentos/Scripts/PDF/"$file_pdf"
  }

  extract_ip_better_pdf() {
      echo "Favor digitar o nome do arquivo: "
      read file_pdf
      msg 'Otimizando PDF...'
      better_quality_pdf /home/$USER/Documentos/Scripts/PDF/"$file_pdf"
      msg 'Extraindo IPs encontrados no arquivo...'
      extract_ips_pdf /home/$USER/Documentos/Scripts/PDF/"$file_pdf"
  }
  
  instructions() {
       echo 'Instruções de uso:'
       echo
       echo '1- Os arquivos PDF a serem otimizados devem estar no diretório /home/'$USER'/Documentos/Scripts/PDF'
       echo '2- Os arquivos otimizados estarão no diretório /home/'$USER'/Documentos/Scripts/PDF/Otimizados'
       echo '3- Se o diretório não existir, você pode criá-lo usando o comando mkdir /home/'$USER'/Documentos/Scripts && mkdir /home/'$USER'/Documentos/Scripts/PDF && mkdir /home/'$USER'/Documentos/Scripts/PDF/Otimizados'
       echo
   }

# ─────────────────────────────────────────────────────────────────────────────
# Show banner and menu
# ─────────────────────────────────────────────────────────────────────────────

      print_banner() {
        echo -e "${GREEN}
        
 ╔════════════════════════════════════════════════════════════════════════╗
 ║            Script de Otimização e extração de dados PDF                ║
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
        echo '1  - Otimizar PDF e extrair IPs' 
        echo '2  - Somente otimizar o PDF'
        echo '3  - Somente extrair os IPs do PDF'
        echo 'i  - Instruções para usar esse script'
        echo 's  - Sair'
        echo
    }

# ─────────────────────────────────────────────────────────────────────────────
# Function to script execute
# ─────────────────────────────────────────────────────────────────────────────

    main() {
       while true; do
         print_banner
         show_menu
         read -p 'Digite sua escolha: ' choice
         case $choice in
         1)  
             extract_ip_better_pdf
             msg 'Otimizado PDF e extraído IP'
             ;;
         2)
             better_pdf
             msg 'Optimizado PDF!'
             ;;
         3)
             extract_ips
             msg 'Extraído lista de IPs do PDF!'
             ;;
         i)
             instructions
             ;;
         s)
             msg 'Até mais!'
             exit 0
             ;;
         *)
             error_msg 'Opção inválida. Por favor, selecione um número ou "s" para sair.'
         esac
       done
    }
 
   (return 2> /dev/null) || main
