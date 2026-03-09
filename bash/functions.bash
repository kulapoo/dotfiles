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
  if ! git rev-parse --abbrev-ref HEAD 2>/dev/null; then
    log_error "[gbr] Failed to get current git branch - not in a git repository"
    return 1
  fi
}

# Extract various archive formats
extract () {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)  tar -jxvf "$1" || { log_error "[extract] Failed to extract tar.bz2 file: $1"; return 1; } ;;
            *.tar.gz)   tar -zxvf "$1" || { log_error "[extract] Failed to extract tar.gz file: $1"; return 1; } ;;
            *.bz2)      bunzip2 "$1" || { log_error "[extract] Failed to extract bz2 file: $1"; return 1; } ;;
            *.dmg)      hdiutil mount "$1" || { log_error "[extract] Failed to mount dmg file: $1"; return 1; } ;;
            *.gz)       gunzip "$1" || { log_error "[extract] Failed to extract gz file: $1"; return 1; } ;;
            *.tar)      tar -xvf "$1" || { log_error "[extract] Failed to extract tar file: $1"; return 1; } ;;
            *.tbz2)     tar -jxvf "$1" || { log_error "[extract] Failed to extract tbz2 file: $1"; return 1; } ;;
            *.tgz)      tar -zxvf "$1" || { log_error "[extract] Failed to extract tgz file: $1"; return 1; } ;;
            *.zip)      unzip "$1" || { log_error "[extract] Failed to extract zip file: $1"; return 1; } ;;
            *.ZIP)      unzip "$1" || { log_error "[extract] Failed to extract ZIP file: $1"; return 1; } ;;
            *.pax)      cat "$1" | pax -r || { log_error "[extract] Failed to extract pax file: $1"; return 1; } ;;
            *.pax.Z)    uncompress "$1" --stdout | pax -r || { log_error "[extract] Failed to extract pax.Z file: $1"; return 1; } ;;
            *.rar)      unrar x "$1" || { log_error "[extract] Failed to extract rar file: $1"; return 1; } ;;
            *.Z)        uncompress "$1" || { log_error "[extract] Failed to extract Z file: $1"; return 1; } ;;
            *)          log_error "[extract] '$1' cannot be extracted/mounted via extract()"; return 1 ;;
        esac
    else
        log_error "[extract] '$1' is not a valid file"
        return 1
    fi
}

# only for guake but needs to be dynamic on which default terminal is used
# This function duplicates the current terminal tab and changes to the current directory
function dup() {
  # Check if guake is installed
  if ! command -v guake &> /dev/null; then
    log_error "[dup] Guake is not installed. Please install it first."
    return 1
  fi

  # Store current directory and tab name
  CURRENT_DIR=$(pwd) || { log_error "[dup] Failed to get current directory"; return 1; }
  TAB_NAME=$(guake --selected-tablabel 2>/dev/null)

  # Debug output
  log_debug "[dup] Duplicating tab: '$TAB_NAME' in directory: $CURRENT_DIR"

  # Open a new Guake tab with current directory
  if ! guake --new-tab="$CURRENT_DIR" 2>/dev/null; then
    log_error "[dup] Failed to open new Guake tab"
    return 1
  fi

  # Longer delay to ensure tab is ready
  sleep 1

  # Rename the new tab to match the original (if we got a tab name)
  if [ -n "$TAB_NAME" ]; then
    log_debug "[dup] Renaming new tab to: '$TAB_NAME'"
    if guake --rename-current-tab="$TAB_NAME" 2>/dev/null; then
      # Verify the rename worked
      sleep 0.5
      NEW_NAME=$(guake --selected-tablabel 2>/dev/null)
      log_success "[dup] New tab created with name: '$NEW_NAME'"
    else
      log_warning "[dup] Failed to rename tab, but tab was created"
    fi
  else
    log_debug "[dup] No tab name to copy"
  fi
}

# Python uv package manager functions
function uvenv() {
  # Create and activate a Python virtual environment using uv
  if ! command -v uv &> /dev/null; then
    log_error "[uvenv] uv is not installed. Please install it first."
    return 1
  fi

  if [ -z "$1" ]; then
    if ! uv venv 2>/dev/null; then
      log_error "[uvenv] Failed to create virtual environment"
      return 1
    fi
  else
    if ! uv venv "$1" 2>/dev/null; then
      log_error "[uvenv] Failed to create virtual environment: $1"
      return 1
    fi
  fi

  if [ -f .venv/bin/activate ]; then
    source .venv/bin/activate || { log_error "[uvenv] Failed to activate virtual environment"; return 1; }
    log_success "[uvenv] Virtual environment created and activated"
  else
    log_error "[uvenv] Virtual environment created but activation script not found"
    return 1
  fi
}

function uvinstall() {
  # Install Python packages using uv
  if ! command -v uv &> /dev/null; then
    log_error "[uvinstall] uv is not installed. Please install it first."
    return 1
  fi

  if [ -f "requirements.txt" ] && [ $# -eq 0 ]; then
    if uv pip install -r requirements.txt 2>/dev/null; then
      log_success "[uvinstall] Successfully installed packages from requirements.txt"
    else
      log_error "[uvinstall] Failed to install packages from requirements.txt"
      return 1
    fi
  else
    if uv pip install "$@" 2>/dev/null; then
      log_success "[uvinstall] Successfully installed packages: $@"
    else
      log_error "[uvinstall] Failed to install packages: $@"
      return 1
    fi
  fi
}

function uvsync() {
  # Sync Python project dependencies using uv
  if ! command -v uv &> /dev/null; then
    log_error "[uvsync] uv is not installed. Please install it first."
    return 1
  fi

  if [ -f "pyproject.toml" ]; then
    if uv sync 2>/dev/null; then
      log_success "[uvsync] Successfully synced project dependencies"
    else
      log_error "[uvsync] Failed to sync project dependencies"
      return 1
    fi
  else
    log_error "[uvsync] No pyproject.toml found. Use 'uv init' to create a new project."
    return 1
  fi
}

function uvrun() {
  # Run a command in the uv-managed environment
  if ! command -v uv &> /dev/null; then
    log_error "[uvrun] uv is not installed. Please install it first."
    return 1
  fi

  if ! uv run "$@" 2>/dev/null; then
    log_error "[uvrun] Failed to run command: $@"
    return 1
  fi
}

function uvpy() {
  # Install a specific Python version using uv
  if ! command -v uv &> /dev/null; then
    log_error "[uvpy] uv is not installed. Please install it first."
    return 1
  fi

  if [ -z "$1" ]; then
    log_error "[uvpy] Usage: uvpy <python-version>"
    log_info "Example: uvpy 3.11"
    return 1
  fi

  if uv python install "$1" 2>/dev/null; then
    log_success "[uvpy] Successfully installed Python $1"
  else
    log_error "[uvpy] Failed to install Python $1"
    return 1
  fi
}

function uvlist() {
  # List installed Python versions managed by uv
  if ! command -v uv &> /dev/null; then
    log_error "[uvlist] uv is not installed. Please install it first."
    return 1
  fi

  if ! uv python list 2>/dev/null; then
    log_error "[uvlist] Failed to list Python versions"
    return 1
  fi
}

# Alias for quick Python REPL with uv
alias uvpython='uv run python'

# Alias for quick pip operations with uv
alias uvpip='uv pip'

# Temperature monitoring function
function temps() {
    # Check if sensors command is available
    if ! command -v sensors &> /dev/null; then
        log_error "[temps] 'sensors' command not found. Please install lm-sensors:"
        log_info "  sudo apt-get install lm-sensors"
        log_info "  sudo sensors-detect"
        return 1
    fi

    # Parse command line arguments
    local WATCH_MODE=false
    local INTERVAL=2
    local COMPACT=false
    local VERBOSE=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -w|--watch)
                WATCH_MODE=true
                shift
                ;;
            -i|--interval)
                INTERVAL="$2"
                shift 2
                ;;
            -c|--compact)
                COMPACT=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                echo "Usage: temps [OPTIONS]"
                echo ""
                echo "Monitor system temperatures using sensors"
                echo ""
                echo "Options:"
                echo "  -w, --watch          Watch mode - continuously update temperatures"
                echo "  -i, --interval SEC   Update interval in seconds (default: 2)"
                echo "  -c, --compact        Show compact output"
                echo "  -v, --verbose        Show all sensor data"
                echo "  -h, --help          Show this help message"
                echo ""
                echo "Examples:"
                echo "  temps              # Show current temperatures"
                echo "  temps -w           # Watch temperatures (update every 2s)"
                echo "  temps -w -i 5      # Watch with 5 second interval"
                echo "  temps -c           # Compact view"
                echo "  temps -v           # Verbose output with all sensors"
                return 0
                ;;
            *)
                log_error "[temps] Unknown option: $1"
                return 1
                ;;
        esac
    done

    # Function to display temperatures
    display_temps() {
        local sensor_output=$(sensors 2>/dev/null)

        if [ -z "$sensor_output" ]; then
            log_error "[temps] No sensor data available"
            return 1
        fi

        # Clear screen for watch mode
        if [ "$WATCH_MODE" = true ]; then
            clear
        fi

        echo -e "${COLOR_BOLD_CYAN}=== System Temperature Monitor ===${COLOR_NC}"
        echo -e "${COLOR_CYAN}$(date '+%Y-%m-%d %H:%M:%S')${COLOR_NC}\n"

        if [ "$VERBOSE" = true ]; then
            # Show full sensor output with color coding
            echo "$sensor_output" | while IFS= read -r line; do
                if [[ $line =~ ^[A-Za-z] ]] && [[ ! $line =~ Adapter ]]; then
                    # Device name
                    echo -e "${COLOR_BOLD_BLUE}$line${COLOR_NC}"
                elif [[ $line =~ Adapter ]]; then
                    # Adapter line
                    echo -e "${COLOR_PURPLE}$line${COLOR_NC}"
                elif [[ $line =~ temp|Core|Package|Composite|CPU|GPU ]]; then
                    # Temperature lines - color code by value
                    if [[ $line =~ \+([0-9]+\.?[0-9]*) ]]; then
                        temp="${BASH_REMATCH[1]}"
                        temp_int=${temp%%.*}

                        if [ "$temp_int" -ge 80 ]; then
                            echo -e "${COLOR_BOLD_RED}$line${COLOR_NC}"
                        elif [ "$temp_int" -ge 70 ]; then
                            echo -e "${COLOR_YELLOW}$line${COLOR_NC}"
                        elif [ "$temp_int" -ge 60 ]; then
                            echo -e "${COLOR_CYAN}$line${COLOR_NC}"
                        else
                            echo -e "${COLOR_GREEN}$line${COLOR_NC}"
                        fi
                    else
                        echo "$line"
                    fi
                else
                    echo "$line"
                fi
            done
        elif [ "$COMPACT" = true ]; then
            # Compact view - show only key temperatures
            echo -e "${COLOR_BOLD_GREEN}CPU:${COLOR_NC}"

            # CPU Package temperature
            local cpu_package=$(echo "$sensor_output" | grep "Package id 0" | head -1 | grep -oE '\+[0-9]+\.?[0-9]*' | head -1 | tr -d '+')
            if [ -n "$cpu_package" ]; then
                local cpu_int=${cpu_package%%.*}
                if [ "$cpu_int" -ge 80 ]; then
                    echo -e "  Package: ${COLOR_BOLD_RED}${cpu_package}°C${COLOR_NC}"
                elif [ "$cpu_int" -ge 70 ]; then
                    echo -e "  Package: ${COLOR_YELLOW}${cpu_package}°C${COLOR_NC}"
                else
                    echo -e "  Package: ${COLOR_GREEN}${cpu_package}°C${COLOR_NC}"
                fi
            fi

            # Show highest core temp (extract actual temperature values only)
            local max_core_temp=$(echo "$sensor_output" | grep "^Core " | awk '{print $3}' | tr -d '+°C' | sort -rn | head -1)
            if [ -n "$max_core_temp" ]; then
                local temp_int=${max_core_temp%%.*}
                if [ "$temp_int" -ge 80 ]; then
                    echo -e "  Highest Core: ${COLOR_BOLD_RED}${max_core_temp}°C${COLOR_NC}"
                elif [ "$temp_int" -ge 70 ]; then
                    echo -e "  Highest Core: ${COLOR_YELLOW}${max_core_temp}°C${COLOR_NC}"
                else
                    echo -e "  Highest Core: ${COLOR_CYAN}${max_core_temp}°C${COLOR_NC}"
                fi
            fi

            # GPU temperature if available
            local gpu_temp=$(echo "$sensor_output" | grep "GPU temp" | grep -oE '\+[0-9]+\.?[0-9]*' | head -1 | tr -d '+')
            if [ -n "$gpu_temp" ]; then
                echo -e "\n${COLOR_BOLD_GREEN}GPU:${COLOR_NC}"
                echo -e "  Temperature: ${COLOR_CYAN}${gpu_temp}°C${COLOR_NC}"
            fi

            # NVMe temperatures (get only actual composite temperatures)
            local nvme_temps=$(echo "$sensor_output" | grep "^Composite:" | awk '{print $2}' | tr -d '+°C')
            if [ -n "$nvme_temps" ]; then
                echo -e "\n${COLOR_BOLD_GREEN}Storage (NVMe):${COLOR_NC}"
                echo "$nvme_temps" | while read -r temp; do
                    echo -e "  ${COLOR_CYAN}${temp}°C${COLOR_NC}"
                done
            fi

            # Fan speeds if available
            local cpu_fan=$(echo "$sensor_output" | grep "CPU fan" | grep -oE '[0-9]+ RPM')
            local gpu_fan=$(echo "$sensor_output" | grep "GPU fan" | grep -oE '[0-9]+ RPM')

            if [ -n "$cpu_fan" ] || [ -n "$gpu_fan" ]; then
                echo -e "\n${COLOR_BOLD_GREEN}Fans:${COLOR_NC}"
                [ -n "$cpu_fan" ] && echo -e "  CPU: ${COLOR_CYAN}${cpu_fan}${COLOR_NC}"
                [ -n "$gpu_fan" ] && echo -e "  GPU: ${COLOR_CYAN}${gpu_fan}${COLOR_NC}"
            fi
        else
            # Standard view - formatted key information
            echo -e "${COLOR_BOLD_GREEN}CPU Temperatures:${COLOR_NC}"

            # CPU Package
            local cpu_package=$(echo "$sensor_output" | grep "Package id 0" | head -1)
            if [ -n "$cpu_package" ]; then
                local temp=$(echo "$cpu_package" | grep -oE '\+[0-9]+\.?[0-9]*' | head -1 | tr -d '+')
                local temp_int=${temp%%.*}

                echo -n "  Package: "
                if [ "$temp_int" -ge 80 ]; then
                    echo -e "${COLOR_BOLD_RED}${temp}°C${COLOR_NC} ⚠️"
                elif [ "$temp_int" -ge 70 ]; then
                    echo -e "${COLOR_YELLOW}${temp}°C${COLOR_NC}"
                else
                    echo -e "${COLOR_GREEN}${temp}°C${COLOR_NC}"
                fi
            fi

            # CPU Cores summary (extract actual temperature values only)
            local core_temps=$(echo "$sensor_output" | grep "^Core " | awk '{print $3}' | tr -d '+°C' | sort -n)

            if [ -n "$core_temps" ]; then
                local min_temp=$(echo "$core_temps" | head -1)
                local max_temp=$(echo "$core_temps" | tail -1)
                local avg_temp=$(echo "$core_temps" | awk '{sum+=$1} END {printf "%.1f", sum/NR}')

                # Color code the max temp
                local max_int=${max_temp%%.*}
                local max_color="${COLOR_GREEN}"
                if [ "$max_int" -ge 80 ]; then
                    max_color="${COLOR_BOLD_RED}"
                elif [ "$max_int" -ge 70 ]; then
                    max_color="${COLOR_YELLOW}"
                elif [ "$max_int" -ge 60 ]; then
                    max_color="${COLOR_CYAN}"
                fi

                echo -e "  Cores: Min=${COLOR_GREEN}${min_temp}°C${COLOR_NC}, Avg=${COLOR_CYAN}${avg_temp}°C${COLOR_NC}, Max=${max_color}${max_temp}°C${COLOR_NC}"
            fi

            # System76 specific temps if available
            local sys76_cpu=$(echo "$sensor_output" | grep "CPU temp" | grep -oE '\+[0-9]+\.?[0-9]*' | head -1 | tr -d '+')
            local sys76_gpu=$(echo "$sensor_output" | grep "GPU temp" | grep -oE '\+[0-9]+\.?[0-9]*' | head -1 | tr -d '+')

            if [ -n "$sys76_gpu" ]; then
                echo -e "\n${COLOR_BOLD_GREEN}GPU Temperature:${COLOR_NC}"
                echo -e "  Temperature: ${COLOR_CYAN}${sys76_gpu}°C${COLOR_NC}"
            fi

            # Storage temperatures
            echo -e "\n${COLOR_BOLD_GREEN}Storage Temperatures:${COLOR_NC}"

            # NVMe drives
            echo "$sensor_output" | grep -B1 "Composite" | grep "nvme-pci" | while read -r nvme_line; do
                local nvme_id=$(echo "$nvme_line" | cut -d- -f3)
                local next_line=$(echo "$sensor_output" | grep -A1 "$nvme_line" | tail -1)
                local nvme_temp=$(echo "$next_line" | grep -oE '\+[0-9]+\.?[0-9]*' | head -1 | tr -d '+')

                if [ -n "$nvme_temp" ]; then
                    echo -e "  NVMe (${nvme_id}): ${COLOR_CYAN}${nvme_temp}°C${COLOR_NC}"
                fi
            done

            # Memory temperature if available
            local mem_temp=$(echo "$sensor_output" | grep "spd5118" -A2 | grep "temp1" | grep -oE '\+[0-9]+\.?[0-9]*' | head -1 | tr -d '+')
            if [ -n "$mem_temp" ]; then
                echo -e "\n${COLOR_BOLD_GREEN}Memory Temperature:${COLOR_NC}"
                echo -e "  DDR5: ${COLOR_CYAN}${mem_temp}°C${COLOR_NC}"
            fi

            # Fan speeds
            local cpu_fan=$(echo "$sensor_output" | grep "CPU fan" | grep -oE '[0-9]+ RPM')
            local gpu_fan=$(echo "$sensor_output" | grep "GPU fan" | grep -oE '[0-9]+ RPM')

            if [ -n "$cpu_fan" ] || [ -n "$gpu_fan" ]; then
                echo -e "\n${COLOR_BOLD_GREEN}Fan Speeds:${COLOR_NC}"
                [ -n "$cpu_fan" ] && echo -e "  CPU Fan: ${COLOR_CYAN}${cpu_fan}${COLOR_NC}"
                [ -n "$gpu_fan" ] && echo -e "  GPU Fan: ${COLOR_CYAN}${gpu_fan}${COLOR_NC}"
            fi

            # Show warning for high temps (only check actual temperature readings, not thresholds)
            # Extract only actual temperature readings (lines with temp/Core/Package/Composite/CPU/GPU but not "high" or "crit")
            local high_temp=$(echo "$sensor_output" | grep -E "(temp[0-9]*:|Core |Package|Composite:|CPU temp:|GPU temp:)" | \
                grep -v -E "(high|crit|low)" | \
                grep -oE '\+[0-9]+\.?[0-9]*' | tr -d '+' | while read temp; do
                # Filter out obviously invalid temperatures (anything above 125°C is likely wrong)
                temp_int=${temp%%.*}
                if [ "$temp_int" -lt 125 ]; then
                    echo "$temp"
                fi
            done | sort -rn | head -1)

            if [ -n "$high_temp" ]; then
                local high_int=${high_temp%%.*}
                if [ "$high_int" -ge 85 ]; then
                    echo -e "\n${COLOR_BOLD_RED}⚠️  WARNING: High temperature detected (${high_temp}°C)${COLOR_NC}"
                elif [ "$high_int" -ge 80 ]; then
                    echo -e "\n${COLOR_YELLOW}⚠️  CAUTION: Temperature is getting high (${high_temp}°C)${COLOR_NC}"
                fi
            fi
        fi

        if [ "$WATCH_MODE" = true ]; then
            echo -e "\n${COLOR_YELLOW}Press Ctrl+C to exit watch mode${COLOR_NC}"
        fi
    }

    # Run in watch mode or single execution
    if [ "$WATCH_MODE" = true ]; then
        log_info "[temps] Starting watch mode (interval: ${INTERVAL}s)"
        trap 'echo -e "\n${COLOR_GREEN}Temperature monitoring stopped.${COLOR_NC}"; return 0' INT

        while true; do
            display_temps
            sleep "$INTERVAL"
        done
    else
        display_temps
    fi
}

# Alias for quick temperature check
alias temp='temps -c'
alias tempw='temps -w'

# ==================== YOUTUBE TRANSCRIPT FUNCTION ====================
# Copy YouTube transcript to clipboard (works with any YouTube link)
#
# REQUIREMENTS (install once on new machine):
#   # 1. Install uv (Python package manager)
#   curl -LsSf https://astral.sh/uv/install.sh | sh
#
#   # 2. Install clipboard tool (choose one based on your system)
#   # For Wayland:
#   sudo apt install wl-clipboard  # Debian/Ubuntu
#   # OR for X11:
#   sudo apt install xclip         # Debian/Ubuntu
#
#   # 3. Install required Python package
#   uv pip install yt-dlp-transcripts
#
# USAGE:
#   yt-transcript                    # Uses URL from clipboard
#   yt-transcript "youtube_url"      # Uses provided URL
#   yt-transcript --help              # Show help
# =====================================================================

yt-transcript() {
    # Show help if requested
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "📹 YouTube Transcript Copier"
        echo ""
        echo "USAGE:"
        echo "  yt-transcript                    # Uses URL from clipboard"
        echo "  yt-transcript \"youtube_url\"      # Uses provided URL"
        echo ""
        echo "REQUIREMENTS (install once):"
        echo "  # Install uv (if not already installed)"
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        echo ""
        echo "  # Install clipboard tool"
        echo "  sudo apt install wl-clipboard  # for Wayland"
        echo "  # OR"
        echo "  sudo apt install xclip         # for X11"
        echo ""
        echo "  # Install yt-dlp-transcripts as a global tool"
        echo "  uv tool install yt-dlp-transcripts"
        echo ""
        echo "EXAMPLE:"
        echo "  yt-transcript \"https://www.youtube.com/watch?v=dQw4w9WgXcQ\""
        echo "  # Or just copy a URL and run: yt-transcript"
        return 0
    fi

    # Check if required package is installed (using uv tool)
    if ! command -v yt-dlp-transcripts &> /dev/null; then
        echo "❌ yt-dlp-transcripts not found!"
        echo "   Run: uv tool install yt-dlp-transcripts"
        return 1
    fi

    # Function to extract clean video URL (strips ALL other parameters)
    clean_youtube_url() {
        local url="$1"

        # Extract video ID using regex (works with various YouTube URL formats)
        if [[ $url =~ (v=|/)([0-9A-Za-z_-]{11}) ]]; then
            video_id="${BASH_REMATCH[2]}"
            # Return clean URL with ONLY the video ID
            echo "https://www.youtube.com/watch?v=$video_id"
        else
            # If no video ID found, return original URL (might be playlist or channel)
            echo "$url"
        fi
    }

    # Get URL from clipboard if no argument provided
    local INPUT_URL
    if [ -z "$1" ]; then
        # Try Wayland clipboard first
        if command -v wl-paste &> /dev/null; then
            INPUT_URL=$(wl-paste 2>/dev/null)
        # Fallback to xclip
        elif command -v xclip &> /dev/null; then
            INPUT_URL=$(xclip -selection clipboard -o 2>/dev/null)
        else
            echo "❌ No clipboard tool found!"
            echo "   Install wl-clipboard (Wayland) or xclip (X11)"
            echo "   sudo apt install wl-clipboard  # for Wayland"
            echo "   sudo apt install xclip         # for X11"
            return 1
        fi

        # Check if we got anything from clipboard
        if [ -z "$INPUT_URL" ]; then
            echo "❌ Clipboard is empty"
            echo "   Copy a YouTube link first or provide URL as argument"
            return 1
        fi

        # Check if clipboard contains a YouTube URL
        if [[ ! $INPUT_URL =~ (youtube\.com|youtu\.be) ]]; then
            echo "❌ Clipboard doesn't contain a YouTube URL"
            echo "   Current clipboard: $INPUT_URL"
            echo "   Copy a YouTube link first or provide URL as argument"
            return 1
        fi
    else
        INPUT_URL="$1"
    fi

    # Clean the URL (removes ALL extra parameters)
    local CLEAN_URL
    CLEAN_URL=$(clean_youtube_url "$INPUT_URL")

    # Show what we're using (helpful for debugging)
    if [ "$INPUT_URL" != "$CLEAN_URL" ]; then
        echo "📋 Input: $INPUT_URL"
        echo "🔗 Clean URL: $CLEAN_URL"
    fi

    # Create temporary file
    local temp_file
    temp_file=$(mktemp)

    # Download transcript and copy to clipboard
    echo "⏳ Fetching transcript..."

    # Run the tool and capture output
    if yt-dlp-transcripts -u "$CLEAN_URL" -o "$temp_file" 2>/dev/null; then
        # Check if file has content and contains transcript
        if [ -s "$temp_file" ] && grep -q "transcript" "$temp_file"; then
            # Extract transcript column (assuming it's the 5th column) and copy to clipboard
            if command -v wl-copy &> /dev/null; then
                cut -d, -f5 "$temp_file" | sed 's/^"//;s/"$//' | wl-copy
                echo "✅ Transcript copied to clipboard (Wayland)!"
            elif command -v xclip &> /dev/null; then
                cut -d, -f5 "$temp_file" | sed 's/^"//;s/"$//' | xclip -selection clipboard
                echo "✅ Transcript copied to clipboard (X11)!"
            else
                echo "✅ Transcript saved but no clipboard tool found"
                echo "   File location: $temp_file"
                cat "$temp_file"
                return 0
            fi

            # Show preview (first 3 lines, cleaned up)
            echo "📝 Preview:"
            cut -d, -f5 "$temp_file" | sed 's/^"//;s/"$//' | head -n 3 | while read -r line; do
                # Truncate long lines for display
                if [ ${#line} -gt 80 ]; then
                    echo "  ${line:0:77}..."
                else
                    echo "  $line"
                fi
            done

            # Show transcript stats
            local line_count word_count
            line_count=$(cut -d, -f5 "$temp_file" | wc -l)
            word_count=$(cut -d, -f5 "$temp_file" | wc -w)
            echo "📊 Stats: $line_count lines, ~$word_count words"

            # Clean up temp file
            rm -f "$temp_file"
        else
            echo "❌ No transcript found for this video"
            echo "   The video might not have captions available"
            rm -f "$temp_file"
            return 1
        fi
    else
        echo "❌ Failed to get transcript"
        echo "   Possible reasons:"
        echo "   - Video doesn't exist"
        echo "   - No captions available"
        echo "   - Network issue"
        rm  -f  "$temp_file" 2>/dev/null
        return 1
    fi
}
