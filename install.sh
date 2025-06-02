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

    # Common paths to check for hardware-configuration.nix
    declare -a config_paths=(
        "/etc/nixos/hardware-configuration.nix"
        "/home/$USERNAME/meowrch-nixos/hardware-configuration.nix"
        "/home/$USERNAME/nixos/hardware-configuration.nix"
    )
    
    # Check for hardware configuration in common locations
    FOUND_CONFIG=false
    for config_path in "${config_paths[@]}"; do
        if [[ -f "$config_path" ]]; then
            cp "$config_path" ./hardware-configuration.nix
            log_success "Copied hardware configuration from $config_path"
            FOUND_CONFIG=true
            break
        fi
    done
    
    # If not found, ask user for manual path
    if [[ "$FOUND_CONFIG" == "false" ]]; then
        log_warning "No hardware configuration found in common locations."
        echo -e "${CYAN}You can specify a custom path to hardware-configuration.nix${NC}"
        read -p "Enter path to hardware-configuration.nix (or leave empty to generate new): " CUSTOM_PATH
        
        if [[ -n "$CUSTOM_PATH" && -f "$CUSTOM_PATH" ]]; then
            cp "$CUSTOM_PATH" ./hardware-configuration.nix
            log_success "Copied hardware configuration from $CUSTOM_PATH"
        else
            log_warning "No valid path provided, generating new hardware configuration..."
            sudo nixos-generate-config --show-hardware-config > ./hardware-configuration.nix
            log_success "Generated new hardware configuration"
        fi
    fi
    
    # Validate the hardware configuration
    if ! grep -q "fileSystems" ./hardware-configuration.nix; then
        log_warning "The hardware configuration may be incomplete or invalid."
        echo -e "${YELLOW}It doesn't contain filesystem definitions, which are usually required.${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Installation aborted. Please provide a valid hardware configuration."
            exit 1
        fi
    fi
}

customize_config() {
    log_info "Customizing configuration..."

    # Replace username in configuration
    sed -i "s/redm00us/$USERNAME/g" ./configuration.nix
    sed -i "s/redm00us/$USERNAME/g" ./home/home.nix
    sed -i "s/redm00us/$USERNAME/g" ./modules/system/audio.nix
    sed -i "s/redm00us/$USERNAME/g" ./modules/system/bluetooth.nix
    sed -i "s/redm00us/$USERNAME/g" ./modules/system/fonts.nix
    sed -i "s/redm00us/$USERNAME/g" ./modules/system/graphics.nix
    sed -i "s/redm00us/$USERNAME/g" ./modules/system/networking.nix
    sed -i "s/redm00us/$USERNAME/g" ./modules/system/security.nix
    sed -i "s/redm00us/$USERNAME/g" ./flake.nix

    # Replace hostname
    sed -i "s/hostName = \"meowrch\"/hostName = \"$HOSTNAME\"/g" ./modules/system/networking.nix

    # Replace timezone
    sed -i "s|time.timeZone = \".*\"|time.timeZone = \"$TIMEZONE\"|g" ./configuration.nix

    # Configure GPU drivers
    case "$GPU_TYPE" in
        nvidia)
            sed -i 's/# enableNvidia = true;/enableNvidia = true;/g' ./modules/system/graphics.nix
            sed -i 's/# enableIntel = false;/enableIntel = false;/g' ./modules/system/graphics.nix
            sed -i 's/# enableAmd = false;/enableAmd = false;/g' ./modules/system/graphics.nix
            ;;
        amd)
            sed -i 's/# enableNvidia = false;/enableNvidia = false;/g' ./modules/system/graphics.nix
            sed -i 's/# enableIntel = false;/enableIntel = false;/g' ./modules/system/graphics.nix
            sed -i 's/# enableAmd = true;/enableAmd = true;/g' ./modules/system/graphics.nix
            ;;
        intel)
            sed -i 's/# enableNvidia = false;/enableNvidia = false;/g' ./modules/system/graphics.nix
            sed -i 's/# enableIntel = true;/enableIntel = true;/g' ./modules/system/graphics.nix
            sed -i 's/# enableAmd = false;/enableAmd = false;/g' ./modules/system/graphics.nix
            ;;
        hybrid)
            sed -i 's/# enableNvidia = true;/enableNvidia = true;/g' ./modules/system/graphics.nix
            sed -i 's/# enableIntel = true;/enableIntel = true;/g' ./modules/system/graphics.nix
            sed -i 's/# enableAmd = false;/enableAmd = false;/g' ./modules/system/graphics.nix
            ;;
    esac

    # Handle Git repository to prevent "dirty tree" errors
    log_info "Checking Git repository status..."
    if command -v git &> /dev/null && [ -d ".git" ]; then
        # Initialize Git if not already done
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            log_info "Initializing Git repository..."
            git init
        fi
        
        # Add all changes
        git add .
        
        # Commit changes
        git commit -m "Customized Meowrch configuration for $USERNAME on $HOSTNAME" || true
        log_success "Git repository updated with customized configuration"
    else
        # If git not found or not a git repo, initialize one
        if command -v git &> /dev/null; then
            log_info "Setting up Git repository for Meowrch..."
            git init
            git config --local user.name "Meowrch Installer"
            git config --local user.email "meowrch@localhost"
            git add .
            git commit -m "Initial Meowrch configuration for $USERNAME on $HOSTNAME" || true
            log_success "Git repository initialized"
        else
            log_warning "Git not available. This might cause 'dirty tree' errors with Nix Flakes."
            log_info "Install Git and run: git init && git add . && git commit -m 'Initial commit'"
        fi
    fi

    log_success "Configuration customized for $USERNAME on $HOSTNAME"
}




build_system() {
    log_info "Building NixOS configuration..."

    echo -e "${YELLOW}This may take a while (10-30 minutes depending on your internet and hardware)${NC}"

    # Check flake.nix
    if ! [ -f "flake.nix" ]; then
        log_error "flake.nix not found in current directory!"
        exit 1
    fi

    # Build the configuration
    log_info "Running nixos-rebuild (this may take 10-30 minutes)..."
    
    # First try a build dry-run to check for errors
    log_info "Checking configuration validity..."
    if ! sudo nixos-rebuild build --flake ".#meowrch" &>/dev/null; then
        log_warning "Configuration pre-check failed, but continuing with actual build..."
    else
        log_success "Configuration pre-check passed!"
    fi
    
    # Try the actual build
    if sudo nixos-rebuild switch --flake ".#meowrch"; then
        log_success "NixOS configuration built successfully!"
    else
        log_error "Failed to build NixOS configuration!"
        log_info "Check the output above for errors."
        log_warning "Common issues:"
        echo -e "  ${YELLOW}1. Missing or invalid hardware-configuration.nix${NC}"
        echo -e "  ${YELLOW}2. Git repository is dirty (use 'git add . && git commit -m \"Initial commit\"')${NC}"
        echo -e "  ${YELLOW}3. Missing required packages or modules${NC}"
        
        # Try to help fix git issues
        if command -v git &> /dev/null; then
            log_info "Attempting to fix Git repository state..."
            git add .
            git commit -m "Fix dirty state" || true
            echo -e "${CYAN}Retrying build after Git fix...${NC}"
            if sudo nixos-rebuild switch --flake ".#meowrch"; then
                log_success "Build succeeded after fixing Git repository!"
                return 0
            fi
        fi
        
        log_info "You can try to run the command manually:"
        echo -e "  ${CYAN}sudo nixos-rebuild switch --flake .#meowrch${NC}"
        exit 1
    fi
}

setup_home_manager() {
    log_info "Setting up Home Manager..."

    # Switch to the user and run home-manager
    if sudo -u "$USERNAME" home-manager switch --flake ".#redm00us"; then
        log_success "Home Manager configuration applied successfully!"
    else
        log_warning "Home Manager setup failed, but system should still work"
        log_info "You can manually run: home-manager switch --flake .#redm00us"
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
echo -e "  • ${BLUE}Update home config:${NC} home-manager switch --flake .#redm00us"
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
        log_info "You should be in the 'NixOS-25.05' directory containing flake.nix"
        exit 1
    fi

    # Create empty hardware-configuration.nix if it doesn't exist
    # This is needed for flake evaluation before we copy the real one
    if [[ ! -f "hardware-configuration.nix" ]]; then
        cat > hardware-configuration.nix << 'EOF'
# Placeholder hardware-configuration.nix - will be replaced during installation
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # This is a minimal placeholder that will be replaced during installation
  # but is valid enough for flake evaluation
  
  # These are needed for NixOS to evaluate without errors
  fileSystems."/" = {
    device = "/dev/placeholder";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/placeholder-boot";
    fsType = "vfat";
  };

  swapDevices = [ ];
}
EOF
        log_info "Created placeholder hardware-configuration.nix"
    fi
    
    # Ensure Git doesn't cause issues for flake evaluation
    if command -v git &> /dev/null; then
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            log_info "Initializing Git repository to avoid 'dirty tree' errors..."
            git init
            git config --local user.name "Meowrch Installer"
            git config --local user.email "meowrch@localhost"
            git add .
            git commit -m "Initial commit" || true
        fi
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
