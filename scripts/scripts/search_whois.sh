#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
# Declaring Variables
# ─────────────────────────────────────────────────────────────────────────────

# ──────────────────────
# Colors
# ──────────────────────

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[0;33m'

ORANGE='\033[1;33m'    # Aproach Orange

MAGENTA='\033[1;35m'

BLUE='\033[0;34m'

GRAY='\033[1;30m'

RESET='\033[0m'


# ────────────────────────────────────────────────────────────────────────────────────────
# Function to search IP or Domain on Registro.BR Whois and save results
# ────────────────────────────────────────────────────────────────────────────────────────
  execute_registroBR() {
      local dir="/home/$USER/Documents/Scripts/whois/"
      local input_file=$dir"search_whois.txt"
      local output_file=$dir"results_whois_registro_br.txt"
    
      # Check if input file exists
      if [ ! -f "$input_file" ]; then
          echo "Error: The $input_file don't exists!"
          exit 1
      fi

      echo "Saving results on $output_file..."
      > "$output_file"  # clear output file

      # Loop function for input
      while IFS= read -r ip; do
        # Check if input file line is empty
          if [ -n "$ip" ]; then
              echo "Searching info about IP or domain $ip..."
              echo "==== Info about IP or domain $ip ====" >> "$output_file"
              whois -h whois.registro.br "$ip" >> "$output_file" 2>&1
              echo "===============================" >> "$output_file"
              echo -e "\n\n" >> "$output_file"
          fi
      done < "$input_file"

      echo "Search on Registro.br whois finished! Results on $output_file."
  }


# ────────────────────────────────────────────────────────────────────────────────────────
# Function to search IP or Domain on LACNIC Whois and save results
# ────────────────────────────────────────────────────────────────────────────────────────
   execute_lacnic() {
      local dir="/home/$USER/Documents/Scripts/whois/"
      local input_file=$dir"search_whois.txt"  # Arquivo fixo de entrada com IPs ou domínios
      local output_file=$dir"results_whois_lacnic.txt"

      # Check if input file exists
      if [ ! -f "$input_file" ]; then
          echo "Error: the $input_file don't exists!"
          exit 1
      fi

      echo "Saving results on $output_file..."
      > "$output_file"  # clear output file

      # Loop function for input
      while IFS= read -r ip; do
          # Check if input file line is empty
          if [ -n "$ip" ]; then
              echo "Searching info about IP or domain $ip..."
              echo "==== Info about IP or domain $ip ====" >> "$output_file"
              whois -h whois.lacnic.net "$ip" >> "$output_file" 2>&1
              echo "===============================" >> "$output_file"
              echo -e "\n\n" >> "$output_file"
          fi
      done < "$input_file"

      echo "Search on LACNIC whois finished! Results on $output_file."
     }

# ────────────────────────────────────────────────────────────────────────────────────────
# Function to search IP or Domain on the both Whois and save results
# ────────────────────────────────────────────────────────────────────────────────────────

  execute_whois() {
      local dir="/home/$USER/Documents/Scripts/whois/"
      local input_file=$dir"search_whois.txt"
      local output_file=$dir"results_whois.txt"

      # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: the $input_file don't exists!"
        exit 1
    fi

    echo "Saving results on $output_file..."
    > "$output_file"  # clear output file

    # Loop function for input
    while IFS= read -r ip; do
        if [ -n "$ip" ]; then
            echo "Searching info about IP or domain $ip..."
            echo "==== Info about IP or domain $ip ====" >> "$output_file"
            echo >> "$output_file"

            # Try on Registro.br
            local result_registro_br
            result_registro_br=$(whois -h whois.registro.br "$ip" 2>&1)

            # Try on LACNIC
            local result_lacnic
            result_lacnic=$(whois -h whois.lacnic.net "$ip" 2>&1)

            # Write the results on output file
            if [ -n "$result_registro_br" ] && ! echo "$result_registro_br" | grep -q "No match for"; then
                echo "Result from Registro.br:" >> "$output_file"
                echo >> "$output_file"
                echo "$result_registro_br" >> "$output_file"
                echo >> "$output_file"
                echo "===============================" >> "$output_file"
            fi

            if [ -n "$result_lacnic" ] && ! echo "$result_lacnic" | grep -q "No match for"; then
                echo >> "$output_file"
                echo "Result from LACNIC:" >> "$output_file"
                echo >> "$output_file"
                echo "$result_lacnic" >> "$output_file"
                echo >> "$output_file"
                echo "===============================" >> "$output_file"
            fi

            if [ -z "$result_registro_br" ] && [ -z "$result_lacnic" ]; then
                echo "Don't found info about $ip." >> "$output_file"
            fi

            echo "===============================" >> "$output_file"
            echo -e "\n" >> "$output_file"
        fi
    done < "$input_file"

        echo "Search finished! Results on $output_file."
}

# ─────────────────────────────────────────────────────────────────────────────
# Instructions
# ─────────────────────────────────────────────────────────────────────────────
      instructions() {
       echo 'Instruções de uso: '
       echo
       echo '1- Add the IPs or domains to be queried to the file search_whois.txt'
       echo '2- The file search_whois.txt is located in the directory /home/'$USER'/Documents/Scripts/whois'
       echo '3- The files with the query results will also be stored in the same directory'
       echo '4- If the directory does not exist, you can create it using the command mkdir /home/'$USER'/Documents/Scripts && mkdir /home/'$USER'/Documents/Scripts/whois'
       echo
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
# Show banner and menu
# ─────────────────────────────────────────────────────────────────────────────

    print_banner() {
        echo -e "${GREEN}
        
 ╔════════════════════════════════════════════════════════════════════════╗
 ║          Script of search information about IP and Domains             ║
 ║                                                                        ║
 ║                                                                        ║
 ║ By: Kevin Oliveira                                                     ║
 ║ Script Version  : 2.0                                                  ║
 ╚════════════════════════════════════════════════════════════════════════╝
    
        ${RESET}"
    }

    show_menu() {
        echo -e "${ORANGE}Choose what you do: ${RESET}"
        echo
        echo '1  - Search info from Registro.BR whois' 
        echo '2  - Search info from LACNIC whois'
        echo '3  - Search on both'
        echo 'i  - Instruction to use this script'
        echo 'q  - Exit'
        echo
    }

# ─────────────────────────────────────────────────────────────────────────────
# Funções para o script executar as tarefas
# ─────────────────────────────────────────────────────────────────────────────

    main() {
       while true; do
         print_banner
         show_menu
         read -p 'Enter your choose: ' choice
         case $choice in
         1)  
             execute_registroBR
             msg 'Search from Registro.BR whois finished!'
             ;;
         2)
             execute_lacnic
             msg 'Search from LACNIC whois finished!'
             ;;
         3)
             execute_whois
             msg 'Search from whois finished!'
             ;;
         i)
             instructions
             ;;
         q)
             msg 'See you soon!'
             exit 0
             ;;
         *)
             error_msg 'Invalid option. Please, choose a number or "q" to Exit.'
         esac
       done
    }
 
(return 2> /dev/null) || main
