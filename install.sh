#!/usr/bin/env bash

# Meowrch NixOS Installation Script
# A beautiful Hyprland rice for NixOS 25.05

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Art
echo -e "${PURPLE}"
cat << "EOF"
                          ▄▀▄     ▄▀▄           ▄▄▄▄▄
                         ▄█░░▀▀▀▀▀░░█▄         █░▄▄░░█
                     ▄▄  █░░░░░░░░░░░█  ▄▄    █░█  █▄█
                    █▄▄█ █░░▀░░┬░░▀░░█ █▄▄█  █░█
███╗░░░███╗███████╗░█████╗░░██╗░░░░░░░██╗██████╗░░█████╗░██╗░░██╗
████╗░████║██╔════╝██╔══██╗░██║░░██╗░░██║██╔══██╗██╔══██╗██║░░██║
██╔████╔██║█████╗░░██║░░██║░╚██╗████╗██╔╝██████╔╝██║░░╚═╝███████║
██║╚██╔╝██║██╔══╝░░██║░░██║░░████╔═████║░██╔══██╗██║░░██╗██╔══██║
██║░╚═╝░██║███████╗╚█████╔╝░░╚██╔╝░╚██╔╝░██║░░██║╚█████╔╝██║░░██║
╚═╝░░░░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝

                    NixOS 25.05 Installation Script
EOF
echo -e "${NC}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking system requirements..."

    # Check if running NixOS
    if [[ ! -f /etc/NIXOS ]]; then
        log_error "This script must be run on NixOS!"
        exit 1
    fi

    # Check NixOS version
    local nixos_version=$(nixos-version | cut -d'.' -f1-2)
    if [[ "$nixos_version" < "25.05" ]]; then
        log_warning "NixOS version $nixos_version detected. NixOS 25.05+ recommended."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Check if git is available
    if ! command -v git &> /dev/null; then
        log_error "Git is required but not installed!"
        log_info "Installing git..."
        nix-shell -p git --run "echo 'Git installed temporarily'"
    fi

    # Check if flakes are enabled
    if ! nix --help | grep -q flakes; then
        log_error "Nix flakes are not enabled!"
        log_info "Please enable flakes in your configuration first:"
        echo "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"
        exit 1
    fi

    log_success "System requirements check passed!"
}

get_user_info() {
    log_info "Gathering user information..."

    # Get username
    echo -e "${CYAN}Current user: ${NC}$(whoami)"
    read -p "Enter username for Meowrch (default: $(whoami)): " USERNAME
    USERNAME=${USERNAME:-$(whoami)}

    # Get timezone
    echo -e "${CYAN}Current timezone: ${NC}$(timedatectl show --property=Timezone --value)"
    read -p "Enter timezone (default: current): " TIMEZONE
    TIMEZONE=${TIMEZONE:-$(timedatectl show --property=Timezone --value)}

    # Get hostname
    echo -e "${CYAN}Current hostname: ${NC}$(hostname)"
    read -p "Enter hostname (default: meowrch): " HOSTNAME
    HOSTNAME=${HOSTNAME:-meowrch}

    # Graphics card detection
    log_info "Detecting graphics hardware..."

    GPU_TYPE="unknown"
    if lspci | grep -i nvidia > /dev/null; then
        GPU_TYPE="nvidia"
        log_info "NVIDIA GPU detected"
    elif lspci | grep -i amd > /dev/null; then
        GPU_TYPE="amd"
        log_info "AMD GPU detected"
    elif lspci | grep -i intel > /dev/null; then
        GPU_TYPE="intel"
        log_info "Intel GPU detected"
    fi

    echo -e "${CYAN}Detected GPU: ${NC}$GPU_TYPE"
    read -p "Is this correct? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Available GPU types: intel, amd, nvidia, hybrid"
        read -p "Enter GPU type: " GPU_TYPE
    fi

    log_success "User information collected!"
}

backup_current_config() {
    log_info "Backing up current configuration..."

    local backup_dir="/etc/nixos/backup-$(date +%Y%m%d-%H%M%S)"

    if [[ -d /etc/nixos ]]; then
        sudo mkdir -p "$backup_dir"
        sudo cp -r /etc/nixos/* "$backup_dir/" 2>/dev/null || true
        log_success "Current configuration backed up to $backup_dir"
    fi
}

setup_hardware_config() {
    log_info "Setting up hardware configuration..."

    # Copy existing hardware configuration
    if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
        cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
        log_success "Copied existing hardware configuration"
    else
        log_warning "No hardware configuration found, generating new one..."
        sudo nixos-generate-config --show-hardware-config > ./hardware-configuration.nix
        log_success "Generated new hardware configuration"
    fi
}


build_system() {
    log_info "Building NixOS configuration..."

    echo -e "${YELLOW}This may take a while (10-30 minutes depending on your internet and hardware)${NC}"

    # Build the configuration
    if sudo nixos-rebuild switch --flake ".#meowrch"; then
        log_success "NixOS configuration built successfully!"
    else
        log_error "Failed to build NixOS configuration!"
        log_info "Check the output above for errors."
        exit 1
    fi
}

setup_home_manager() {
    log_info "Setting up Home Manager..."

    # Switch to the user and run home-manager
    if sudo -u "$USERNAME" home-manager switch --flake ".#meowrch"; then
        log_success "Home Manager configuration applied successfully!"
    else
        log_warning "Home Manager setup failed, but system should still work"
        log_info "You can manually run: home-manager switch --flake .#meowrch"
    fi
}

post_install_setup() {
    log_info "Running post-installation setup..."

    # Create necessary directories
    sudo -u "$USERNAME" mkdir -p "/home/$USERNAME"/{Pictures,Documents,Downloads,Music,Videos}

    # Set up themes and wallpapers (if script exists)
    if [[ -f "/home/$USERNAME/.config/meowrch/meowrch.py" ]]; then
        sudo -u "$USERNAME" python "/home/$USERNAME/.config/meowrch/meowrch.py" --action set-current-theme || true
        sudo -u "$USERNAME" python "/home/$USERNAME/.config/meowrch/meowrch.py" --action set-wallpaper || true
    fi

    log_success "Post-installation setup completed!"
}

show_completion_message() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   🎉 INSTALLATION COMPLETE! 🎉               ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}🐱 Meowrch NixOS has been successfully installed!${NC}"
    echo
    echo -e "${YELLOW}What's next:${NC}"
    echo -e "  1. ${BLUE}Reboot your system:${NC} sudo reboot"
    echo -e "  2. ${BLUE}Log in and enjoy your new desktop!${NC}"
    echo
    echo -e "${YELLOW}Useful commands:${NC}"
    echo -e "  • ${BLUE}Update system:${NC} sudo nixos-rebuild switch --flake .#meowrch"
    echo -e "  • ${BLUE}Update home config:${NC} home-manager switch --flake .#meowrch"
    echo -e "  • ${BLUE}Change theme:${NC} Super + T"
    echo -e "  • ${BLUE}Change wallpaper:${NC} Super + W"
    echo -e "  • ${BLUE}Open app launcher:${NC} Super + D"
    echo
    echo -e "${YELLOW}Keyboard shortcuts:${NC}"
    echo -e "  • ${BLUE}Terminal:${NC} Super + Enter"
    echo -e "  • ${BLUE}File manager:${NC} Super + E"
    echo -e "  • ${BLUE}Screenshot:${NC} Print Screen"
    echo -e "  • ${BLUE}Lock screen:${NC} Super + L"
    echo
    echo -e "${YELLOW}Documentation:${NC}"
    echo -e "  • ${BLUE}README:${NC} ./README.md"
    echo -e "  • ${BLUE}GitHub:${NC} https://github.com/meowrch/meowrch"
    echo
    echo -e "${GREEN}Thank you for choosing Meowrch! ≽ܫ≼${NC}"
    echo
}

# Main installation process
main() {
    log_info "Starting Meowrch NixOS installation..."

    # Check if we're in the right directory
    if [[ ! -f "flake.nix" ]] || [[ ! -f "configuration.nix" ]]; then
        log_error "Please run this script from the Meowrch NixOS configuration directory!"
        exit 1
    fi

    # Run installation steps
    check_requirements
    get_user_info
    backup_current_config
    setup_hardware_config
    customize_config
    build_system
    setup_home_manager
    post_install_setup
    show_completion_message

    # Ask for reboot
    echo
    read -p "Reboot now to complete installation? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        log_info "Rebooting in 3 seconds... (Ctrl+C to cancel)"
        sleep 1
        echo "2..."
        sleep 1
        echo "1..."
        sleep 1
        sudo reboot
    else
        log_info "Please reboot manually when ready: sudo reboot"
    fi
}

# Error handling
trap 'log_error "Installation failed! Check the output above for details."' ERR

# Run main function
main "$@"
