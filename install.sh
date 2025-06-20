#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Meowrch NixOS 25.05 Universal Installer              ║
# ║                         Универсальный установщик                         ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                              CONFIGURATION                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Глобальные переменные
DEFAULT_USERNAME="meowrch"
DEFAULT_USER_FULLNAME="Meowrch User"
DEFAULT_USER_EMAIL="user@example.com"
DEFAULT_GIT_NAME="Meowrch User"

CURRENT_USERNAME=""
CURRENT_USER_FULLNAME=""
CURRENT_USER_EMAIL=""
CURRENT_GIT_NAME=""
CONFIG_DIR="/home/$USER/meowrch-nixos"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                COLORS                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             LOGGING FUNCTIONS                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝

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

log_header() {
    echo
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

log_step() {
    echo -e "${CYAN}➤${NC} $1"
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                            UTILITY FUNCTIONS                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Отображение ASCII логотипа
show_logo() {
    echo -e "${PURPLE}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════════════════════════╗
    ║                                                                          ║
    ║   ███╗   ███╗███████╗ ██████╗ ██╗    ██╗██████╗  ██████╗██╗  ██╗          ║
    ║   ████╗ ████║██╔════╝██╔═══██╗██║    ██║██╔══██╗██╔════╝██║  ██║          ║
    ║   ██╔████╔██║█████╗  ██║   ██║██║ █╗ ██║██████╔╝██║     ███████║          ║
    ║   ██║╚██╔╝██║██╔══╝  ██║   ██║██║███╗██║██╔══██╗██║     ██╔══██║          ║
    ║   ██║ ╚═╝ ██║███████╗╚██████╔╝╚███╔███╔╝██║  ██║╚██████╗██║  ██║          ║
    ║   ╚═╝     ╚═╝╚══════╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝          ║
    ║                                                                          ║
    ║                           NixOS 25.05 Edition                           ║
    ║                        Universal Installer v2.0                         ║
    ║                                                                          ║
    ╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Проверка прав пользователя
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run this script as root!"
        log_info "The script will request sudo when needed."
        exit 1
    fi
}

# Проверка системы
check_system() {
    log_header "System Requirements Check"

    # Проверка NixOS
    if [[ ! -f /etc/NIXOS ]]; then
        log_error "This script must be run on NixOS!"
        exit 1
    fi

    log_success "Running on NixOS ✓"

    # Проверка команд
    local commands=("git" "nix" "sudo")
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    log_success "All required commands available ✓"

    # Проверка sudo
    if ! sudo -n true 2>/dev/null; then
        log_info "Testing sudo access..."
        sudo true
    fi

    log_success "Sudo access confirmed ✓"
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                         USER CONFIGURATION                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Функция ввода с валидацией
prompt_input() {
    local prompt="$1"
    local default="$2"
    local validation_regex="${3:-.*}"
    local error_msg="${4:-Invalid input}"
    local result=""

    while true; do
        echo -ne "${CYAN}$prompt${NC}"
        if [[ -n "$default" ]]; then
            echo -ne " ${YELLOW}(default: $default)${NC}"
        fi
        echo -n ": "

        read -r result

        # Использовать default если ввод пустой
        if [[ -z "$result" && -n "$default" ]]; then
            result="$default"
        fi

        # Валидация
        if [[ "$result" =~ $validation_regex ]]; then
            echo "$result"
            return 0
        else
            log_error "$error_msg"
        fi
    done
}

# Настройка пользователя
configure_user() {
    log_header "User Configuration"

    log_info "Configure your user account settings:"
    echo

    # Имя пользователя
    CURRENT_USERNAME=$(prompt_input \
        "Username" \
        "$DEFAULT_USERNAME" \
        "^[a-z][a-z0-9_-]*$" \
        "Username must start with lowercase letter and contain only lowercase letters, numbers, hyphens, and underscores")

    # Полное имя
    CURRENT_USER_FULLNAME=$(prompt_input \
        "Full Name" \
        "$DEFAULT_USER_FULLNAME" \
        "^[A-Za-z ]+$" \
        "Full name must contain only letters and spaces")

    # Email
    CURRENT_USER_EMAIL=$(prompt_input \
        "Email" \
        "$DEFAULT_USER_EMAIL" \
        "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$" \
        "Please enter a valid email address")

    # Git имя
    CURRENT_GIT_NAME=$(prompt_input \
        "Git Name" \
        "$CURRENT_USER_FULLNAME" \
        "^[A-Za-z ]+$" \
        "Git name must contain only letters and spaces")

    echo
    log_info "Configuration summary:"
    log_step "Username: $CURRENT_USERNAME"
    log_step "Full Name: $CURRENT_USER_FULLNAME"
    log_step "Email: $CURRENT_USER_EMAIL"
    log_step "Git Name: $CURRENT_GIT_NAME"
    echo

    # Подтверждение
    local confirm
    confirm=$(prompt_input "Is this correct? (y/n)" "y" "^[yYnN]$" "Please enter y or n")

    if [[ "$confirm" =~ ^[nN]$ ]]; then
        log_info "Let's try again..."
        configure_user
        return
    fi

    log_success "User configuration saved!"
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                        CONFIGURATION REPLACEMENT                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Замена пользователя в файлах
replace_user_config() {
    log_header "Updating Configuration Files"

    local files=(
        "configuration.nix"
        "flake.nix"
        "home/home.nix"
        "home/modules/waybar.nix"
        "modules/system/security.nix"
    )

    # Определяем CONFIG_DIR правильно
    CONFIG_DIR=$(pwd)

    for file in "${files[@]}"; do
        local filepath="$CONFIG_DIR/$file"

        if [[ -f "$filepath" ]]; then
            log_step "Updating $file..."

            # Создаем резервную копию
            cp "$filepath" "$filepath.backup"

            # Замены для configuration.nix
            if [[ "$file" == "configuration.nix" ]]; then
                sed -i "s/users\.redm00us/users.$CURRENT_USERNAME/g" "$filepath"
                sed -i "s/\"Meowrch User\"/\"$CURRENT_USER_FULLNAME\"/g" "$filepath"
            fi

            # Замены для flake.nix
            if [[ "$file" == "flake.nix" ]]; then
                sed -i "s/home-manager\.users\.redm00us/home-manager.users.$CURRENT_USERNAME/g" "$filepath"
                sed -i "s/redm00us = home-manager/\"$CURRENT_USERNAME\" = home-manager/g" "$filepath"
                sed -i "s/#redm00us\"/#$CURRENT_USERNAME\"/g" "$filepath"
            fi

            # Замены для home/home.nix
            if [[ "$file" == "home/home.nix" ]]; then
                # Основные настройки
                sed -i "s/home\.username = \"redm00us\"/home.username = \"$CURRENT_USERNAME\"/g" "$filepath"
                sed -i "s|home\.homeDirectory = \"/home/redm00us\"|home.homeDirectory = \"/home/$CURRENT_USERNAME\"|g" "$filepath"

                # Git настройки
                sed -i "s/userName = \"Redm00us\"/userName = \"$CURRENT_GIT_NAME\"/g" "$filepath"
                sed -i "s/userEmail = \"krokismau@icloud\.com\"/userEmail = \"$CURRENT_USER_EMAIL\"/g" "$filepath"

                # Пути в алиасах
                sed -i "s|/home/redm00us/NixOS-25.05|/home/$CURRENT_USERNAME/meowrch-nixos|g" "$filepath"
                sed -i "s|/home/redm00us/config-backups|/home/$CURRENT_USERNAME/config-backups|g" "$filepath"
                sed -i "s|\.#redm00us|.#$CURRENT_USERNAME|g" "$filepath"
            fi

            # Замены для home/modules/waybar.nix
            if [[ "$file" == "home/modules/waybar.nix" ]]; then
                sed -i "s|/home/redm00us/|/home/$CURRENT_USERNAME/|g" "$filepath"
            fi

            # Замены для modules/system/security.nix
            if [[ "$file" == "modules/system/security.nix" ]]; then
                sed -i "s/users = \[ \"redm00us\" \]/users = [ \"$CURRENT_USERNAME\" ]/g" "$filepath"
            fi

            log_success "✓ $file updated"
        else
            log_warning "⚠ $file not found, skipping..."
        fi
    done

    log_success "All configuration files updated!"
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                         HARDWARE CONFIGURATION                           ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Генерация конфигурации оборудования
generate_hardware_config() {
    log_header "Hardware Configuration"

    log_info "Generating hardware configuration..."

    # Проверяем, есть ли уже hardware-configuration.nix
    if [[ -f ./hardware-configuration.nix ]]; then
        local replace
        replace=$(prompt_input "hardware-configuration.nix already exists. Replace it? (y/n)" "n" "^[yYnN]$")

        if [[ "$replace" =~ ^[nN]$ ]]; then
            log_info "Keeping existing hardware-configuration.nix"
            return 0
        fi
    fi

    # Генерируем конфигурацию
    if sudo nixos-generate-config --show-hardware-config > ./hardware-configuration.nix; then
        log_success "Hardware configuration generated!"

        # Показываем информацию о файловых системах
        log_info "Detected filesystems:"
        grep -E "device.*=|fsType.*=" ./hardware-configuration.nix | sed 's/^[[:space:]]*/  /' || true
    else
        log_error "Failed to generate hardware configuration!"
        return 1
    fi
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                            SYSTEM INSTALLATION                           ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Валидация конфигурации
validate_configuration() {
    log_header "Configuration Validation"

    log_info "Running configuration validation..."

    if [[ -x ./validate-config.sh ]]; then
        if ./validate-config.sh; then
            log_success "Configuration validation passed!"
        else
            log_error "Configuration validation failed!"
            return 1
        fi
    else
        log_warning "validate-config.sh not found or not executable, skipping validation"
    fi
}

# Создание резервной копии
create_backup() {
    log_header "Creating Backup"

    local backup_dir="./backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # Копируем текущую конфигурацию
    if [[ -d /etc/nixos ]]; then
        sudo cp -r /etc/nixos/* "$backup_dir/" 2>/dev/null || true
        log_info "Current NixOS configuration backed up"
    fi

    # Копируем пользовательские конфиги
    if [[ -d ~/.config ]]; then
        cp -r ~/.config "$backup_dir/user-config" 2>/dev/null || true
        log_info "User configuration backed up"
    fi

    log_success "Backup created in $backup_dir"
}

# Сборка системы
build_system() {
    log_header "Building NixOS System"

    log_info "Starting system build... This may take a while."
    log_warning "Do not interrupt the build process!"

    # Проверяем, что мы в Git репозитории
    if [[ ! -d .git ]]; then
        log_info "Initializing Git repository..."
        git init
        git add .
        git commit -m "Initial Meowrch NixOS configuration for $CURRENT_USERNAME"
    fi

    # Сборка с использованием flake
    log_info "Building system configuration..."
    if sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure; then
        log_success "System build completed successfully!"
    else
        log_error "System build failed!"
        log_info "Check the output above for details."
        return 1
    fi
}

# Настройка Home Manager
setup_home_manager() {
    log_header "Setting up Home Manager"

    log_info "Configuring Home Manager for user: $CURRENT_USERNAME"

    # Переключаемся на пользователя для выполнения Home Manager
    if sudo -u "$CURRENT_USERNAME" home-manager switch --flake ".#$CURRENT_USERNAME" 2>/dev/null; then
        log_success "Home Manager configured successfully!"
    else
        log_warning "Home Manager setup will be completed on first login"
        log_info "User can run: home-manager switch --flake .#$CURRENT_USERNAME"
    fi
}

# Финализация установки
finalize_installation() {
    log_header "Installation Finalization"

    # Создаем пользователя если он не существует
    if ! id "$CURRENT_USERNAME" &>/dev/null; then
        log_info "Creating user: $CURRENT_USERNAME"
        sudo useradd -m -c "$CURRENT_USER_FULLNAME" \
            -G wheel,networkmanager,audio,video,storage,optical,bluetooth \
            -s "$(which fish)" "$CURRENT_USERNAME"

        # Устанавливаем пароль
        log_info "Setting password for $CURRENT_USERNAME"
        sudo passwd "$CURRENT_USERNAME"
    else
        log_info "User $CURRENT_USERNAME already exists"
    fi

    # Копируем конфигурацию в домашнюю директорию пользователя
    local user_config_dir="/home/$CURRENT_USERNAME/meowrch-nixos"
    sudo mkdir -p "$user_config_dir"
    sudo cp -r ./* "$user_config_dir/"
    sudo chown -R "$CURRENT_USERNAME:$CURRENT_USERNAME" "$user_config_dir"

    log_success "Configuration copied to $user_config_dir"

    # Информация для пользователя
    echo
    log_success "🎉 Meowrch NixOS installation completed!"
    echo
    log_info "Next steps:"
    log_step "1. Reboot your system: sudo reboot"
    log_step "2. Login as: $CURRENT_USERNAME"
    log_step "3. Your configuration is in: $user_config_dir"
    log_step "4. Useful aliases are available in Fish shell:"
    log_step "   - 'rebuild' or 'b' - rebuild system"
    log_step "   - 'update' or 'u' - update and rebuild"
    log_step "   - 'config' or 'c' - open config in editor"
    log_step "   - 'home' or 'hm' - apply Home Manager"
    echo
    log_info "For more aliases, check: cat $user_config_dir/ALIASES.md"
    echo
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                              MAIN MENU                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Основное меню
show_main_menu() {
    while true; do
        clear
        show_logo

        echo -e "${WHITE}Welcome to Meowrch NixOS Universal Installer!${NC}"
        echo
        echo -e "${CYAN}Please select an option:${NC}"
        echo
        echo "1) 🚀 Full Installation (Recommended)"
        echo "2) ⚙️ Configure User Only"
        echo "3) 🔧 Generate Hardware Config"
        echo "4) ✅ Validate Configuration"
        echo "5) 📦 Build System Only"
        echo "6) 🏠 Setup Home Manager Only"
        echo "7) ℹ️ System Information"
        echo "8) 📚 Help"
        echo "9) 🚪 Exit"
        echo

        local choice
        choice=$(prompt_input "Your choice" "1" "^[1-9]$" "Please enter a number from 1-9")

        case $choice in
            1) full_installation ;;
            2) configure_user ;;
            3) generate_hardware_config ;;
            4) validate_configuration ;;
            5) build_system_only ;;
            6) setup_home_manager_only ;;
            7) show_system_info ;;
            8) show_help ;;
            9) exit 0 ;;
            *) log_error "Invalid option" ;;
        esac

        echo
        read -p "Press Enter to continue..."
    done
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                            INSTALLATION FLOWS                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Полная установка
full_installation() {
    log_header "Full Meowrch NixOS Installation"

    # Проверки
    check_system

    # Настройка пользователя
    configure_user

    # Создание бэкапа
    create_backup

    # Генерация hardware config
    generate_hardware_config

    # Замена конфигурации
    replace_user_config

    # Валидация
    validate_configuration

    # Сборка системы
    build_system

    # Настройка Home Manager
    setup_home_manager

    # Финализация
    finalize_installation
}

# Сборка только системы
build_system_only() {
    log_header "System Build Only"

    check_system

    if [[ -z "$CURRENT_USERNAME" ]]; then
        log_info "User configuration needed for build"
        configure_user
        replace_user_config
    fi

    validate_configuration
    build_system
}

# Настройка только Home Manager
setup_home_manager_only() {
    log_header "Home Manager Setup Only"

    if [[ -z "$CURRENT_USERNAME" ]]; then
        configure_user
        replace_user_config
    fi

    setup_home_manager
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                            UTILITY FUNCTIONS                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Информация о системе
show_system_info() {
    log_header "System Information"

    echo "System Details:"
    echo "┌─────────────────┬──────────────────────────────────────┐"
    printf "│ %-15s │ %-36s │\n" "OS" "$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    printf "│ %-15s │ %-36s │\n" "Kernel" "$(uname -r)"
    printf "│ %-15s │ %-36s │\n" "Architecture" "$(uname -m)"
    printf "│ %-15s │ %-36s │\n" "Hostname" "$(hostname)"
    printf "│ %-15s │ %-36s │\n" "User" "$(whoami)"
    printf "│ %-15s │ %-36s │\n" "Shell" "$SHELL"
    echo "└─────────────────┴──────────────────────────────────────┘"

    echo
    echo "Hardware Info:"
    echo "┌─────────────────┬──────────────────────────────────────┐"
    printf "│ %-15s │ %-36s │\n" "CPU" "$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
    printf "│ %-15s │ %-36s │\n" "Memory" "$(free -h | grep '^Mem:' | awk '{print $2}')"
    printf "│ %-15s │ %-36s │\n" "Disk Usage" "$(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}')"
    echo "└─────────────────┴──────────────────────────────────────┘"
}

# Справка
show_help() {
    log_header "Help & Usage Information"

    echo "Meowrch NixOS Universal Installer"
    echo "═══════════════════════════════════"
    echo
    echo "This installer helps you set up Meowrch NixOS with your custom user configuration."
    echo
    echo "FEATURES:"
    echo "• Universal username configuration"
    echo "• Automatic hardware detection"
    echo "• Configuration validation"
    echo "• Backup creation"
    echo "• Home Manager integration"
    echo "• 150+ useful shell aliases"
    echo
    echo "INSTALLATION OPTIONS:"
    echo "1. Full Installation - Complete setup process (recommended)"
    echo "2. Configure User - Set up username and personal details"
    echo "3. Hardware Config - Generate hardware-configuration.nix"
    echo "4. Validate Config - Check configuration for errors"
    echo "5. Build System - Build and apply NixOS configuration"
    echo "6. Home Manager - Set up user environment"
    echo
    echo "REQUIREMENTS:"
    echo "• Running NixOS system"
    echo "• sudo access"
    echo "• Internet connection"
    echo "• At least 20GB free space"
    echo
    echo "AFTER INSTALLATION:"
    echo "• Reboot your system"
    echo "• Login with your configured username"
    echo "• Enjoy your Meowrch NixOS setup!"
    echo
    echo "For more information, visit:"
    echo "https://github.com/Redm00us/meowrch-nixos"
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                              MAIN EXECUTION                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Обработка аргументов командной строки
handle_arguments() {
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --user-config)
            configure_user
            exit 0
            ;;
        --hardware-config)
            generate_hardware_config
            exit 0
            ;;
        --validate)
            validate_configuration
            exit 0
            ;;
        --build)
            build_system_only
            exit 0
            ;;
        --home-manager)
            setup_home_manager_only
            exit 0
            ;;
        --full)
            full_installation
            exit 0
            ;;
        --info)
            show_system_info
            exit 0
            ;;
        "")
            # Нет аргументов - показать меню
            ;;
        *)
            log_error "Unknown argument: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Основная функция
main() {
    # Проверка прав
    check_permissions

    # Обработка аргументов
    handle_arguments "$@"

    # Показать интерактивное меню
    show_main_menu
}

# Trap для очистки при выходе
cleanup() {
    log_info "Cleaning up..."
    # Удаляем временные файлы если нужно
}

trap cleanup EXIT

# Запуск основной функции
main "$@"
