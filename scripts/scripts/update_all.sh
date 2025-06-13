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
      echo -e "${YELLOW}Want to restart now? ${RESET}"
      echo
      while true; do
         read -p 'Enter your option (y/n): ' choice
         if [[ "$choice" == 'y' || "$choice" == 'Y' ]]; then
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
 ║                           Updates Manager                              ║
 ║                                                                        ║
 ║                                                                        ║
 ║ By: Kevin Oliveira                                                     ║
 ║ Script version: 1.0                                                    ║
 ╚════════════════════════════════════════════════════════════════════════╝

        ${RESET}"
    }
    show_menu() {
        echo -e "${ORANGE}Choose what to do: ${RESET}"
        echo
        echo -e "${ORANGE}Updating repositories packages: ${RESET}"
        echo '1  - Update all' 
        echo '2  - Repository update'
        echo '3  - Packages update'
        echo '4  - Packages and dependencies update'
        echo '5  - Snap packages update'
        echo '6  - Flatpak packages update'
        echo -e "${ORANGE}Updating .deb packages: ${RESET}"
        echo '7  - Google Chrome update'
        echo '8  - Free Download Manager update'
        echo 'q  - Exit'
        echo
    }
    
# ─────────────────────────────────────────────────────────────────────────────
# Functions of the script task execution
# ─────────────────────────────────────────────────────────────────────────────
    
  main() {
         print_banner
         show_menu
         read -p 'Enter your choice: ' choice
         case $choice in
         1)
             unlock_apt_dpkg
             auto
             msg 'Updates applied successfully!'
             ask_reboot
             ;;
         2)
             unlock_apt_dpkg
             repo_update
             msg 'Updates applied successfully!'
             ;;
         3)
             unlock_apt_dpkg
             repo_update
             msg 'Updating applications...'
             upgrade
             msg 'Updates applied successfully!'
             ask_reboot
             ;;
         4)
             unlock_apt_dpkg
             repo_update
             msg 'Updating dependencies and applications...'
             dist_upgrade
             msg 'Updates applied successfully!'
             ask_reboot
             ;;
         5)
             snap_update
             msg 'Updates applied successfully!'
             ask_reboot
             ;;
         6)
             flatpak_update
             msg 'Updates applied successfully!'
             ask_reboot
             ;;
         7)
             unlock_apt_dpkg
             chrome_update
             msg 'Updates applied successfully!'
             ask_reboot
             ;;
         8)
             unlock_apt_dpkg
             fdm_update
             msg 'Updates applied successfully!'
             ask_reboot
             ;;
 
         q)
             msg 'See you soon!'
             exit 0
             ;;
         *)
             error_msg 'Invalid option. Please choose a valid number or "q" to quit.'
         esac

    }
 
   auto() {
        repo_update
        msg 'Updating applications...'
        upgrade
        msg 'Updating dependencies and applications...'
        dist_upgrade
        msg 'Updating snap packages...'
        snap_update
        msg 'Updating flatpak packages...'
        flatpak_update
        msg 'Updating Google Chrome...'
        chrome_update
        msg 'Updating Free Download Manager...'
        fdm_update
        msg 'Cleaning up...'
        cleanup
        unlock_apt_dpkg
    }

(return 2> /dev/null) || main
