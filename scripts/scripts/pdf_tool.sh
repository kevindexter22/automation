#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
# Declaring variables
# ─────────────────────────────────────────────────────────────────────────────

# ──────────────────────
# Colors
# ──────────────────────

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[0;33m'

ORANGE='\033[1;33m'    # Aproach orange

MAGENTA='\033[1;35m'

BLUE='\033[0;34m'

GRAY='\033[1;30m'

RESET='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
# Function to extract IP of PDF file
# ─────────────────────────────────────────────────────────────────────────────
  extract_ips_pdf() {
    local file_pdf="$1"
    local file_txt="extracted_ip.txt"

    # Check if PDF exist
    if [ ! -f "$file_pdf" ]; then
       echo "The file $file_pdf don't found!"
       exit 1
    fi

    echo "Found IPs on file $file_pdf:" > /home/$USER/Documents/Scripts/PDF/"$file_txt" 

    # Convert PDF file to image .png
    pdftoppm "$file_pdf" temp_page -png
    for img in temp_page-*.png; do
       echo "Generating image: $img"

    # Using Tresseract OCR to extract image
    tesseract "$img" temp_text -c preserve_interword_spaces=1

    # check if Tesseract created the text file
    if [ -f temp_text.txt ]; then
            # Extract IPv4 and IPv6 to file txt 
            grep -oP '\b(?:\d{1,3}\.){3}\d{1,3}\b' temp_text.txt >> /home/$USER/Documents/Scripts/PDF/"$file_txt"  # IPv4
            grep -oP '\b([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\b' temp_text.txt >> /home/$USER/Documents/Scripts/PDF/"$file_txt"  # IPv6
            # Delete the temp file
            rm temp_text.txt
        fi
        
     # Detele a temp image
     rm "$img"
   
   done
 }
   
# ─────────────────────────────────────────────────────────────────────────────
# Function to leave PDF file better
# ─────────────────────────────────────────────────────────────────────────────
  better_quality_pdf() {
        local file_pdf="$1"
    local output_dir="/home/$USER/Documents/Scripts/PDF/Optimized"
    local optimized_pdf="optimized_pdf.pdf"

    # Verificar se o arquivo PDF existe
    if [ ! -f "$file_pdf" ]; then
        echo "The file $file_pdf was not found!"
        exit 1
    fi

    # Criar diretório de saída, se necessário
    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir"
    fi

    # Otimizar o PDF
    echo "Optimizing PDF to better quality..."
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$output_dir/$optimized_pdf" "$file_pdf"

    # Verificar se o PDF otimizado foi criado
    if pdfinfo "$output_dir/$optimized_pdf" > /dev/null 2>&1; then
        echo "Optimized PDF saved as $output_dir/$optimized_pdf"
    else
        echo "Error to create optimized pdf!"
        exit 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Message function
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
# Function to load PDF file
# ─────────────────────────────────────────────────────────────────────────────

  extract_ips() {
      echo "Please, enter the name of PDF file: "
      read file_pdf
      msg 'Extracting IPs founded on PDF file...'
      extract_ips_pdf /home/$USER/Documents/Scripts/PDF/"$file_pdf"
  }

  better_pdf() {
      echo "Please, enter the name of PDF file: "
      read file_pdf
      msg 'Optimizing PDF file...'
      better_quality_pdf /home/$USER/Documents/Scripts/PDF/"$file_pdf"
  }

  extract_ip_better_pdf() {
      echo "Please, enter the name of PDF file: "
      read file_pdf
      msg 'Optimizing PDF file...'
      better_quality_pdf /home/$USER/Documents/Scripts/PDF/"$file_pdf"
      msg 'Extracting IPs founded on PDF file...'
      extract_ips_pdf /home/$USER/Documents/Scripts/PDF/"$file_pdf"
  }
  
  instructions() {
       echo 'Instructions for use: '
       echo
       echo '1- The PDF files to be optimized must be in the directory /home/'$USER'/Documents/Scripts/PDF'
       echo '2- The optimized files will be in /home/'$USER'/Documents/Scripts/PDF/Optimized'
       echo '3- If the directory does not exist, you can create it using the command mkdir /home/'$USER'/Documents/Scripts && mkdir /home/'$USER'/Documents/Scripts/PDF && /home/'$USER'/Documents/Scripts/PDF/Optimized'
       echo
  }

# ─────────────────────────────────────────────────────────────────────────────
# Show banner and menu
# ─────────────────────────────────────────────────────────────────────────────

    print_banner() {
        echo -e "${GREEN}
        
 ╔════════════════════════════════════════════════════════════════════════╗
 ║                PDF optimizing and extract data                         ║
 ║                                                                        ║
 ║                                                                        ║
 ║ By: Kevin Oliveira                                                     ║
 ║ Script version: 2.0                                                    ║
 ╚════════════════════════════════════════════════════════════════════════╝
    
        ${RESET}"
    }

    show_menu() {
        echo -e "${ORANGE}Choose what to do: ${RESET}"
        echo
        echo '1 - PDF optimize and extract IP address' 
        echo '2 - Just optimize the PDF file'
        echo '3 - Just extract the IP address of PDF file'
        echo 'i - Instructions to use this script'
        echo 'q - Exit'
        echo
    }

# ─────────────────────────────────────────────────────────────────────────────
# Function to script execute
# ─────────────────────────────────────────────────────────────────────────────

    main() {
       while true; do
         print_banner
         show_menu
         read -p 'Enter your option: ' choice
         case $choice in
         1)  
             extract_ip_better_pdf
             msg 'Optimized PDF and extracted IP'
             ;;
         2)
             better_pdf
             msg 'Optimized PDF!'
             ;;
         3)
             extract_ips
             msg 'Extracted IP list of PDF file!'
             ;;
         i)
             instructions
             ;;
         q)
             msg 'See you soon!'
             exit 0
             ;;
         *)
             error_msg 'Ivalid option. Please choose a number or "q" to exit.'
         esac
       done
    }
 
   (return 2> /dev/null) || main
