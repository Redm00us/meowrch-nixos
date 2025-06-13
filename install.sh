#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                    NixOS 25.05 Meowrch Installer                        ║
# ║                         Author: Redm00us                                 ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ────────────── Colors for output ──────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ────────────── ASCII Art ──────────────
show_logo() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════════════════════════╗
    ║                                                                          ║
    ║    ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗    ██████╗ ███████╗ ██████╗   ║
    ║    ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝    ╚════██╗██╔════╝██╔═══██╗  ║
    ║    ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗     █████╔╝███████╗██║   ██║  ║
    ║    ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║    ██╔═══╝ ╚════██║██║   ██║  ║
    ║    ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║    ███████╗███████║╚██████╔╝  ║
    ║    ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚══════╝╚══════╝ ╚═════╝   ║
    ║                                                                          ║
    ║                    🐱 Meowrch Configuration 🐱                           ║
    ║                      Optimized Version                                   ║
    ║                                                                          ║
    ╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Welcome to NixOS 25.05 Meowrch Installer!${NC}"
    echo -e "${WHITE}This script will help you install and configure the system.${NC}"
    echo ""
}

# ────────────── Logging functions ──────────────
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# ────────────── Confirmation function ──────────────
confirm() {
    local prompt="$1"
    local default="${2:-n}"

    if [[ $default == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -p "$prompt" -n 1 -r
    echo

    if [[ $default == "y" ]]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
    else
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

# ────────────── System check ──────────────
check_system() {
    log_step "Checking system..."

    # Check if we're on NixOS
    if [[ ! -f /etc/NIXOS ]]; then
        log_error "This script must be run on NixOS!"
        exit 1
    fi

    # Check NixOS version
    if command -v nixos-version &> /dev/null; then
        local version
        version=$(nixos-version)
        log_info "NixOS Version: $version"
    fi

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run this script as root!"
        log_info "Use a regular user. The script will ask for sudo when needed."
        exit 1
    fi

    # Check sudo availability
    if ! command -v sudo &> /dev/null; then
        log_error "sudo not found! Install sudo and add user to wheel group."
        exit 1
    fi

    # Check sudo access
    if ! sudo -n true 2>/dev/null; then
        log_info "Checking sudo access..."
        if ! sudo true; then
            log_error "No sudo access!"
            exit 1
        fi
    fi

    log_success "System check completed"
}

# ────────────── Setup hardware configuration ──────────────
setup_hardware_config() {
    log_step "Setting up hardware configuration..."

    if [[ -f hardware-configuration.nix ]]; then
        log_warning "hardware-configuration.nix already exists"
        if confirm "Overwrite existing file?"; then
            sudo cp /etc/nixos/hardware-configuration.nix .
            log_success "hardware-configuration.nix updated"
        else
            log_info "Using existing hardware-configuration.nix"
        fi
    else
        if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
            sudo cp /etc/nixos/hardware-configuration.nix .
            sudo chown $USER:users hardware-configuration.nix
            log_success "hardware-configuration.nix copied"
        else
            log_warning "/etc/nixos/hardware-configuration.nix not found"
            log_info "Generating new hardware-configuration.nix..."
            sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
            log_success "hardware-configuration.nix generated"
        fi
    fi
}

# ────────────── Configure user ──────────────
configure_user() {
    log_step "Configuring user..."

    local current_user
    current_user=$(whoami)

    echo -e "${CYAN}Current user: ${WHITE}$current_user${NC}"

    if confirm "Use current user ($current_user)?"; then
        local username="$current_user"
    else
        read -p "Enter username: " username
    fi

    # Update configuration.nix
    if [[ "$username" != "redm00us" ]]; then
        log_info "Updating username in configuration.nix..."
        sed -i "s/redm00us/$username/g" configuration.nix
        log_success "configuration.nix updated"

        # Update home.nix
        log_info "Updating username in home/home.nix..."
        sed -i "s/redm00us/$username/g" home/home.nix
        log_success "home/home.nix updated"

        # Update flake.nix
        log_info "Updating username in flake.nix..."
        sed -i "s/redm00us/$username/g" flake.nix
        log_success "flake.nix updated"
    else
        log_info "Username unchanged"
    fi

    # Git configuration (if needed)
    echo ""
    if confirm "Configure Git settings?"; then
        read -p "Enter your name for Git: " git_name
        read -p "Enter your email for Git: " git_email

        # Update home.nix
        sed -i "s/userName = \"Redm00us\";/userName = \"$git_name\";/g" home/home.nix
        sed -i "s/userEmail = \"krokismau@icloud.com\";/userEmail = \"$git_email\";/g" home/home.nix
        log_success "Git configuration updated"
    fi
}

# ────────────── Configure system ──────────────
configure_system() {
    log_step "Configuring system..."

    # Timezone
    echo -e "${CYAN}Timezone Configuration${NC}"
    local current_timezone
    current_timezone=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Europe/Moscow")
    echo "Current timezone: $current_timezone"

    if confirm "Change timezone? (current: $current_timezone)"; then
        echo "Example timezones:"
        echo "  Europe/Moscow"
        echo "  Europe/Kiev"
        echo "  Europe/London"
        echo "  America/New_York"
        echo "  Asia/Tokyo"
        echo ""
        read -p "Enter timezone: " timezone

        # Update configuration.nix
        sed -i "s|time.timeZone = \".*\";|time.timeZone = \"$timezone\";|g" configuration.nix
        log_success "Timezone updated: $timezone"
    fi

    # Locale
    echo ""
    echo -e "${CYAN}Locale Configuration${NC}"
    if confirm "Change locale? (current: ru_UA.UTF-8)"; then
        echo "Example locales:"
        echo "  en_US.UTF-8"
        echo "  ru_RU.UTF-8"
        echo "  uk_UA.UTF-8"
        echo ""
        read -p "Enter locale: " locale

        # Update configuration.nix
        sed -i "s|i18n.defaultLocale = \".*\";|i18n.defaultLocale = \"$locale\";|g" configuration.nix
        log_success "Locale updated: $locale"
    fi
}

# ────────────── Build system ──────────────
build_system() {
    log_step "Building and applying configuration..."

    echo -e "${YELLOW}This may take some time...${NC}"
    echo ""

    # Check flake
    log_info "Checking flake configuration..."
    if ! nix flake check --no-build 2>/dev/null; then
        log_warning "Found issues with flake, but continuing..."
    fi

    # Build system
    log_info "Building system..."
    if sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure; then
        log_success "System successfully built and applied!"
    else
        log_error "Error building system!"
        echo ""
        log_info "Possible solutions:"
        echo "  1. Check hardware-configuration.nix"
        echo "  2. Check settings in configuration.nix"
        echo "  3. Run: sudo nixos-rebuild switch --flake .#meowrch --show-trace"
        echo ""
        if confirm "Try again with verbose output?"; then
            sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure --show-trace
        else
            exit 1
        fi
    fi
}

# ────────────── Setup Home Manager ──────────────
setup_home_manager() {
    log_step "Setting up Home Manager..."

    # Apply Home Manager configuration
    log_info "Applying Home Manager configuration..."
    if home-manager switch --flake .#$(whoami); then
        log_success "Home Manager successfully configured!"
    else
        log_warning "Error setting up Home Manager"
        log_info "Try later: home-manager switch --flake .#$(whoami)"
    fi
}

# ────────────── Post-installation ──────────────
post_install() {
    log_step "Final setup..."

    # Add Flathub (if needed)
    if confirm "Add Flathub repository for Flatpak?"; then
        log_info "Adding Flathub..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        log_success "Flathub added"
    fi

    # Create important directories
    log_info "Creating user directories..."
    mkdir -p ~/.local/bin
    mkdir -p ~/.config/meowrch
    log_success "Directories created"

    # Check system
    log_info "Checking system..."
    if command -v fastfetch &> /dev/null; then
        echo ""
        fastfetch
    fi
}

# ────────────── Main menu ──────────────
main_menu() {
    while true; do
        show_logo
        echo -e "${WHITE}Choose an action:${NC}"
        echo ""
        echo "  1) 🚀 Full installation (recommended)"
        echo "  2) ⚙️  System check only"
        echo "  3) 🔧 Setup hardware-configuration.nix"
        echo "  4) 👤 Configure user"
        echo "  5) 🌍 Configure system (timezone, locale)"
        echo "  6) 🏗️  Build system"
        echo "  7) 🏠 Setup Home Manager"
        echo "  8) 📋 Show system information"
        echo "  9) ❌ Exit"
        echo ""
        read -p "Enter number (1-9): " choice

        case $choice in
            1)
                full_installation
                break
                ;;
            2)
                check_system
                read -p "Press Enter to continue..."
                ;;
            3)
                setup_hardware_config
                read -p "Press Enter to continue..."
                ;;
            4)
                configure_user
                read -p "Press Enter to continue..."
                ;;
            5)
                configure_system
                read -p "Press Enter to continue..."
                ;;
            6)
                build_system
                read -p "Press Enter to continue..."
                ;;
            7)
                setup_home_manager
                read -p "Press Enter to continue..."
                ;;
            8)
                show_system_info
                read -p "Press Enter to continue..."
                ;;
            9)
                log_info "Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid choice!"
                sleep 2
                ;;
        esac
    done
}

# ────────────── Full installation ──────────────
full_installation() {
    show_logo
    echo -e "${WHITE}Starting full NixOS 25.05 Meowrch installation...${NC}"
    echo ""

    if ! confirm "Continue with full installation?" "y"; then
        return
    fi

    check_system
    setup_hardware_config
    configure_user
    configure_system
    build_system
    setup_home_manager
    post_install

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                  ║${NC}"
    echo -e "${GREEN}║            🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉            ║${NC}"
    echo -e "${GREEN}║                                                                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}What's next:${NC}"
    echo "  1. Reboot the system: ${WHITE}sudo reboot${NC}"
    echo "  2. After reboot, log into Hyprland"
    echo "  3. Use Fish shell aliases:"
    echo "     • ${WHITE}f${NC} - show system information"
    echo "     • ${WHITE}c${NC} - open config in Zed Editor"
    echo "     • ${WHITE}b${NC} - rebuild system"
    echo "     • ${WHITE}u${NC} - update and rebuild"
    echo ""
    echo -e "${PURPLE}Hyprland shortcuts:${NC}"
    echo "  • ${WHITE}Super + Enter${NC} - terminal"
    echo "  • ${WHITE}Super + D${NC} - application menu"
    echo "  • ${WHITE}Super + Alt + C${NC} - Zed Editor"
    echo "  • ${WHITE}Super + E${NC} - file manager"
    echo ""

    if confirm "Reboot system now?" "y"; then
        log_info "Rebooting system..."
        sudo reboot
    fi
}

# ────────────── System information ──────────────
show_system_info() {
    clear
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                        SYSTEM INFORMATION                        ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if command -v fastfetch &> /dev/null; then
        fastfetch
    else
        echo "NixOS Version: $(nixos-version 2>/dev/null || echo 'Unknown')"
        echo "Kernel: $(uname -r)"
        echo "User: $(whoami)"
        echo "Home: $HOME"
        echo "Shell: $SHELL"
    fi

    echo ""
    echo -e "${CYAN}Configuration status:${NC}"
    [[ -f hardware-configuration.nix ]] && echo "✓ hardware-configuration.nix found" || echo "✗ hardware-configuration.nix missing"
    [[ -f flake.nix ]] && echo "✓ flake.nix found" || echo "✗ flake.nix missing"
    [[ -f configuration.nix ]] && echo "✓ configuration.nix found" || echo "✗ configuration.nix missing"
    [[ -f home/home.nix ]] && echo "✓ home.nix found" || echo "✗ home.nix missing"

    echo ""
    echo -e "${CYAN}Available commands:${NC}"
    command -v nixos-rebuild >/dev/null && echo "✓ nixos-rebuild" || echo "✗ nixos-rebuild"
    command -v home-manager >/dev/null && echo "✓ home-manager" || echo "✗ home-manager"
    command -v nix >/dev/null && echo "✓ nix" || echo "✗ nix"
    command -v git >/dev/null && echo "✓ git" || echo "✗ git"
}

# ────────────── Command line arguments handling ──────────────
case "${1:-}" in
    --check)
        check_system
        ;;
    --hardware)
        setup_hardware_config
        ;;
    --user)
        configure_user
        ;;
    --system)
        configure_system
        ;;
    --build)
        build_system
        ;;
    --home)
        setup_home_manager
        ;;
    --full)
        full_installation
        ;;
    --info)
        show_system_info
        ;;
    --help|-h)
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  --check     Check system"
        echo "  --hardware  Setup hardware-configuration.nix"
        echo "  --user      Configure user"
        echo "  --system    Configure system (timezone, locale)"
        echo "  --build     Build system"
        echo "  --home      Setup Home Manager"
        echo "  --full      Full installation"
        echo "  --info      Show system information"
        echo "  --help      Show this help"
        echo ""
        echo "Without arguments, runs interactive menu."
        ;;
    "")
        main_menu
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for help."
        exit 1
        ;;
esac
