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

# ─────────────────────────────────────────────────────────────────────────────
# Função para extrair IPs (tanto v4 como v6) do PDF
# ─────────────────────────────────────────────────────────────────────────────
  extrair_ips_pdf() {
    local ARQUIVO_PDF="$1"
    local ARQUIVO_TXT="ips_extraidos.txt"

    # Valida se o PDF existe
    if [ ! -f "$ARQUIVO_PDF" ]; then
       echo "O arquivo $ARQUIVO_PDF não foi encontrado!"
       exit 1
    fi

    echo "IPs encontrados no arquivo $ARQUIVO_PDF:" > /home/$USER/Documentos/PDF/"$ARQUIVO_TXT" 

    # Converte o PDF para imagens (uma por página)
    pdftoppm "$ARQUIVO_PDF" temp_page -png
    for img in temp_page-*.png; do
       echo "Processando imagem: $img"

    # Usa o Tresseract OCR para extrair texto da imagem
    tesseract "$img" temp_text -c preserve_interword_spaces=1

    # Verifica se o Tesseract gerou o arquivo de texto
    if [ -f temp_text.txt ]; then
            # Extrai os IPs IPv4 e IPv6 do texto gerado
            grep -oP '\b(?:\d{1,3}\.){3}\d{1,3}\b' temp_text.txt >> /home/$USER/Documentos/PDF/"$ARQUIVO_TXT"  # IPv4
            grep -oP '\b([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\b' temp_text.txt >> /home/$USER/Documentos/PDF/"$ARQUIVO_TXT"  # IPv6
            # Remove o arquivo temporário de texto
            rm temp_text.txt
        fi
        
     # Remove a imagem temporária
     rm "$img"
   
   done
 }
   
# ─────────────────────────────────────────────────────────────────────────────
# Função para melhorar a qualidade do PDF e extrair o conteúdo em modo texto
# ─────────────────────────────────────────────────────────────────────────────
  melhorar_pdf_qualidade() {
    local ARQUIVO_PDF="$1"
    local PDF_OTIMIZADO="pdf_otimizado.pdf"

    # Verifica se o arquivo de PDF existe
    if [ ! -f "$ARQUIVO_PDF" ]; then
       echo "O arquivo $ARQUIVO_PDF não foi encontrado!"
       exit 1
    fi
   
    # Otimiza o PDF ajustando contraste, brilho e resolução
    echo "Otimização do PDF para melhorar legibilidade..."
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=pdf_otimizado.pdf "$ARQUIVO_PDF"
  
    # Confirma se o PDF otimizado foi criado
    if pdfinfo "$PDF_OTIMIZADO" > /dev/null 2>&1; then
       echo "PDF otimizado salvo como $PDF_OTIMIZADO"
    else
       echo "Erro ao criar o PDF otimizado!"
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
# Função para carregar PDF
# ─────────────────────────────────────────────────────────────────────────────

  extrair_ips() {
      echo "Por favor, insira o nome do arquivo PDF: "
      read ARQUIVO_PDF
      msg 'Extraindo os IPs encontrados no PDF...'
      extrair_ips_pdf /home/$USER/Documentos/PDF/"$ARQUIVO_PDF"
  }

  melhorar_pdf() {
      echo "Por favor, insira o caminho do arquivo PDF: "
      read ARQUIVO_PDF
      msg 'Otimizando o PDF...'
      melhorar_pdf_qualidade /home/$USER/Documentos/PDF/"$ARQUIVO_PDF"
  }

  extrair_ip_melhorar_pdf() {
      echo "Por favor, insira o caminho do arquivo PDF: "
      read ARQUIVO_PDF
      msg 'Otimizando o PDF...'
      melhorar_pdf_qualidade /home/$USER/Documentos/PDF/"$ARQUIVO_PDF"
      msg 'Extraindo os IPs encontrados no PDF...'
      extrair_ips_pdf /home/$USER/Documentos/PDF/"$ARQUIVO_PDF"
  }

# ─────────────────────────────────────────────────────────────────────────────
# Mostrar banner e menu
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
             extrair_ip_melhorar_pdf
             msg 'Otimizado PDF e extraído os IPs'
             break
             ;;
         2)
             melhorar_pdf
             msg 'PDF otimizado!'
             break
             ;;
         3)
             extrair_ips
             msg 'Extraído IPs do arquivo PDF!'
             break
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
