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

# Get current git branch
function gbr {
  git rev-parse --abbrev-ref HEAD
}

# Extract various archive formats
extract () {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)  tar -jxvf "$1"                        ;;
            *.tar.gz)   tar -zxvf "$1"                        ;;
            *.bz2)      bunzip2 "$1"                          ;;
            *.dmg)      hdiutil mount "$1"                    ;;
            *.gz)       gunzip "$1"                           ;;
            *.tar)      tar -xvf "$1"                         ;;
            *.tbz2)     tar -jxvf "$1"                        ;;
            *.tgz)      tar -zxvf "$1"                        ;;
            *.zip)      unzip "$1"                            ;;
            *.ZIP)      unzip "$1"                            ;;
            *.pax)      cat "$1" | pax -r                     ;;
            *.pax.Z)    uncompress "$1" --stdout | pax -r     ;;
            *.rar)      unrar x "$1"                          ;;
            *.Z)        uncompress "$1"                       ;;
            *)          echo "'$1' cannot be extracted/mounted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# This function duplicates the current Guake tab and changes to the current directory
function dup() {
  # Check if guake is installed
  if ! command -v guake &> /dev/null; then
    echo "Error: Guake is not installed. Please install it first."
    return 1
  fi

  # Store current directory and tab name
  CURRENT_DIR=$(pwd)
  TAB_NAME=$(guake --selected-tablabel 2>/dev/null)

  # Debug output
  echo "Duplicating tab: '$TAB_NAME' in directory: $CURRENT_DIR"

  # Open a new Guake tab with current directory
  guake --new-tab="$CURRENT_DIR"

  # Longer delay to ensure tab is ready
  sleep 1

  # Rename the new tab to match the original (if we got a tab name)
  if [ -n "$TAB_NAME" ]; then
    echo "Renaming new tab to: '$TAB_NAME'"
    guake --rename-current-tab="$TAB_NAME"

    # Verify the rename worked
    sleep 0.5
    NEW_NAME=$(guake --selected-tablabel 2>/dev/null)
    echo "New tab name is: '$NEW_NAME'"
  else
    echo "No tab name to copy"
  fi
}

# Python uv package manager functions
function uvenv() {
  # Create and activate a Python virtual environment using uv
  if [ -z "$1" ]; then
    uv venv
  else
    uv venv "$1"
  fi
  source .venv/bin/activate
}

function uvinstall() {
  # Install Python packages using uv
  if [ -f "requirements.txt" ] && [ $# -eq 0 ]; then
    uv pip install -r requirements.txt
  else
    uv pip install "$@"
  fi
}

function uvsync() {
  # Sync Python project dependencies using uv
  if [ -f "pyproject.toml" ]; then
    uv sync
  else
    echo "No pyproject.toml found. Use 'uv init' to create a new project."
  fi
}

function uvrun() {
  # Run a command in the uv-managed environment
  uv run "$@"
}

function uvpy() {
  # Install a specific Python version using uv
  if [ -z "$1" ]; then
    echo "Usage: uvpy <python-version>"
    echo "Example: uvpy 3.11"
    return 1
  fi
  uv python install "$1"
}

function uvlist() {
  # List installed Python versions managed by uv
  uv python list
}

# Alias for quick Python REPL with uv
alias uvpython='uv run python'

# Alias for quick pip operations with uv
alias uvpip='uv pip'