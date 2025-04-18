export COLOR_NC='\e[0m'

# Regular Colors
export COLOR_RED='\e[0;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_YELLOW='\e[0;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_CYAN='\e[0;36m'

# Bold Colors
export COLOR_BOLD_RED='\e[1;31m'
export COLOR_BOLD_GREEN='\e[1;32m'
export COLOR_BOLD_YELLOW='\e[1;33m'
export COLOR_BOLD_BLUE='\e[1;34m'
export COLOR_BOLD_PURPLE='\e[1;35m'
export COLOR_BOLD_CYAN='\e[1;36m'

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $1"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1" >&2
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${COLOR_PURPLE}[DEBUG]${COLOR_NC} $1"
    fi
}

log_section() {
    echo -e "\n${COLOR_BOLD_CYAN}=== $1 ===${COLOR_NC}\n"
}


function gbr {
  git rev-parse --abbrev-ref HEAD
}

extract () {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)  tar -jxvf $1                        ;;
            *.tar.gz)   tar -zxvf $1                        ;;
            *.bz2)      bunzip2 $1                          ;;
            *.dmg)      hdiutil mount $1                    ;;
            *.gz)       gunzip $1                           ;;
            *.tar)      tar -xvf $1                         ;;
            *.tbz2)     tar -jxvf $1                        ;;
            *.tgz)      tar -zxvf $1                        ;;
            *.zip)      unzip $1                            ;;
            *.ZIP)      unzip $1                            ;;
            *.pax)      cat $1 | pax -r                     ;;
            *.pax.Z)    uncompress $1 --stdout | pax -r     ;;
            *.rar)      unrar x $1                          ;;
            *.Z)        uncompress $1                       ;;
            *)          echo "'$1' cannot be extracted/mounted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# This function duplicates the current Yakuake tab and changes to the previous directory
dup() {
  # Store current directory
  CURRENT_DIR=$(pwd)

  # Open a new tab
  dbus-send --session --type=method_call --dest=org.kde.yakuake /yakuake/sessions org.kde.yakuake.addSession > /dev/null

  # Small delay to ensure tab is ready
  sleep 0.1

  # Run cd command in the new tab to change to the previous directory
  dbus-send --session --type=method_call --dest=org.kde.yakuake /yakuake/sessions org.kde.yakuake.runCommandInTerminal string:"cd '$CURRENT_DIR'"
}

