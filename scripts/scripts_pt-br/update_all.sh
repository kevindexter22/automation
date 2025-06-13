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
# Cleanup function
# ─────────────────────────────────────────────────────────────────────────────

    cleanup() {
        apt autoremove -y
    }

# ─────────────────────────────────────────────────────────────────────────────
# Function to updates
# ─────────────────────────────────────────────────────────────────────────────

  repo_update(){
      sudo apt update
  }

  upgrade(){
      sudo apt upgrade -y
  }

  dist_upgrade(){
      sudo apt dist-upgrade -y
  }

  flatpak_update(){
      sudo flatpak update -y
  }

  snap_update(){
      sudo snap refresh
  }

  chrome_update(){
      sudo wget --max-redirect 100 https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 
      sudo dpkg -i google-chrome*
      sudo apt --fix-broken install
      sudo rm -fr google-chrome*
  }
  
  fdm_update(){
       sudo wget --max-redirect 100 https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
       sudo dpkg -i freedownloadmanager.deb
       sudo apt --fix-broken install
       sudo rm -fr freedownloadmanager.deb
  }

   unlock_apt_dpkg(){
      sudo rm /var/lib/dpkg/lock
      sudo rm /var/lib/apt/lists/lock
      sudo dpkg --configure -a
  }
# ─────────────────────────────────────────────────────────────────────────────
# Restart function
# ─────────────────────────────────────────────────────────────────────────────

    ask_reboot() {
      echo
      echo -e "${YELLOW}Deseja reiniciar agora? ${RESET}"
      echo
      while true; do
         read -p 'Digite sua opção (s/n): ' choice
         if [[ "$choice" == 's' || "$choice" == 'S' ]]; then
                   reboot
                   exit 0
         fi
         if [[ "$choice" == 'n' || "$choice" == 'N' ]]; then
                   break
         fi
     done
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
# Options menu
# ─────────────────────────────────────────────────────────────────────────────

    print_banner() {
        echo -e "${GREEN}

 ╔════════════════════════════════════════════════════════════════════════╗
 ║                     Gerenciador de atualizações                        ║
 ║                                                                        ║
 ║                                                                        ║
 ║ By: Kevin Oliveira                                                     ║
 ║ Script version: 1.0                                                    ║
 ╚════════════════════════════════════════════════════════════════════════╝

        ${RESET}"
    }
    show_menu() {
        echo -e "${ORANGE}Escolha o que deseja fazer: ${RESET}"
        echo
        echo -e "${ORANGE}Atualizar a partir dos repositórios: ${RESET}"
        echo '1  - Atualizar tudo' 
        echo '2  - Atualizar repositórios'
        echo '3  - Atualizar pacotes'
        echo '4  - Atualizar pacotes e dependências'
        echo '5  - Atualizar pacotes snap'
        echo '6  - Atualizar pacotes flatpak'
        echo -e "${ORANGE}Atualizar os aplicações .deb: ${RESET}"
        echo '7  - Atualizar Google Chrome'
        echo '8  - Atualizar Free Download Manager'
        echo 's  - Sair'
        echo
    }
    
# ─────────────────────────────────────────────────────────────────────────────
# Functions of the script task execution
# ─────────────────────────────────────────────────────────────────────────────
    
  main() {
         print_banner
         show_menu
         read -p 'Digite sua opção: ' choice
         case $choice in
         1)
             unlock_apt_dpkg
             auto
             msg 'Atualizações realizadas com sucesso!'
             ask_reboot
             ;;
         2)
             unlock_apt_dpkg
             repo_update
             msg 'Atualizações realizadas com sucesso!'
             ;;
         3)
             unlock_apt_dpkg
             repo_update
             msg 'Atualizando os pacotes...'
             upgrade
             msg 'Atualizações realizadas com sucesso!'
             ask_reboot
             ;;
         4)
             unlock_apt_dpkg
             repo_update
             msg 'Atualizando os pacotes e as dependências...'
             dist_upgrade
             msg 'Atualizações realizadas com sucesso!'
             ask_reboot
             ;;
         5)
             snap_update
             msg 'Atualizações realizadas com sucesso!'
             ask_reboot
             ;;
         6)
             flatpak_update
             msg 'Atualizações realizadas com sucesso!'
             ask_reboot
             ;;
         7)
             unlock_apt_dpkg
             chrome_update
             msg 'Atualizações realizadas com sucesso!'
             ask_reboot
             ;;
         8)
             unlock_apt_dpkg
             fdm_update
             msg 'Atualizações realizadas com sucesso!'
             ask_reboot
             ;;
 
         s)
             msg 'Até mais!'
             exit 0
             ;;
         *)
             error_msg 'Opção inválida. Por favor selecione uma opção válida ou "s" para sair.'
         esac

    }
 
   auto() {
        repo_update
        msg 'Atualizando os pacotes...'
        upgrade
        msg 'Atualizando as dependências...'
        dist_upgrade
        msg 'Atualizando os pacotes snap...'
        snap_update
        msg 'Atualizando os pacotes flatpak...'
        flatpak_update
        msg 'Atualizando o Google Chrome...'
        chrome_update
        msg 'Atualizando o Free Download Manager...'
        fdm_update
        msg 'Limpando os caches...'
        cleanup
        unlock_apt_dpkg
    }

(return 2> /dev/null) || main
