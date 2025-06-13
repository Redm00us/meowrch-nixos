#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                    Установщик NixOS 25.05 Meowrch                       ║
# ║                         Автор: Redm00us                                  ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ────────────── Цвета для вывода ──────────────
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
    ║                      Оптимизированная версия                             ║
    ║                                                                          ║
    ╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Добро пожаловать в установщик NixOS 25.05 Meowrch!${NC}"
    echo -e "${WHITE}Этот скрипт поможет вам установить и настроить систему.${NC}"
    echo ""
}

# ────────────── Функции логирования ──────────────
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

# ────────────── Функция подтверждения ──────────────
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

# ────────────── Проверка системы ──────────────
check_system() {
    log_step "Проверка системы..."

    # Проверяем, что мы на NixOS
    if [[ ! -f /etc/NIXOS ]]; then
        log_error "Этот скрипт должен запускаться на NixOS!"
        exit 1
    fi

    # Проверяем версию NixOS
    if command -v nixos-version &> /dev/null; then
        local version
        version=$(nixos-version)
        log_info "Версия NixOS: $version"
    fi

    # Проверяем права root
    if [[ $EUID -eq 0 ]]; then
        log_error "Не запускайте этот скрипт от root!"
        log_info "Используйте обычного пользователя. Скрипт сам запросит sudo когда нужно."
        exit 1
    fi

    # Проверяем наличие sudo
    if ! command -v sudo &> /dev/null; then
        log_error "sudo не найден! Установите sudo и добавьте пользователя в группу wheel."
        exit 1
    fi

    # Проверяем доступ sudo
    if ! sudo -n true 2>/dev/null; then
        log_info "Проверяем доступ sudo..."
        if ! sudo true; then
            log_error "Нет доступа к sudo!"
            exit 1
        fi
    fi

    log_success "Проверка системы завершена"
}

# ────────────── Копирование hardware-configuration.nix ──────────────
setup_hardware_config() {
    log_step "Настройка конфигурации оборудования..."

    if [[ -f hardware-configuration.nix ]]; then
        log_warning "hardware-configuration.nix уже существует"
        if confirm "Перезаписать существующий файл?"; then
            sudo cp /etc/nixos/hardware-configuration.nix .
            log_success "hardware-configuration.nix обновлен"
        else
            log_info "Использую существующий hardware-configuration.nix"
        fi
    else
        if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
            sudo cp /etc/nixos/hardware-configuration.nix .
            sudo chown $USER:users hardware-configuration.nix
            log_success "hardware-configuration.nix скопирован"
        else
            log_warning "Не найден /etc/nixos/hardware-configuration.nix"
            log_info "Генерирую новый hardware-configuration.nix..."
            sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
            log_success "hardware-configuration.nix сгенерирован"
        fi
    fi
}

# ────────────── Настройка пользователя ──────────────
configure_user() {
    log_step "Настройка пользователя..."

    local current_user
    current_user=$(whoami)

    echo -e "${CYAN}Текущий пользователь: ${WHITE}$current_user${NC}"

    if confirm "Использовать текущего пользователя ($current_user)?"; then
        local username="$current_user"
    else
        read -p "Введите имя пользователя: " username
    fi

    # Обновляем configuration.nix
    if [[ "$username" != "redm00us" ]]; then
        log_info "Обновляю имя пользователя в configuration.nix..."
        sed -i "s/redm00us/$username/g" configuration.nix
        log_success "configuration.nix обновлен"

        # Обновляем home.nix
        log_info "Обновляю имя пользователя в home/home.nix..."
        sed -i "s/redm00us/$username/g" home/home.nix
        log_success "home/home.nix обновлен"

        # Обновляем flake.nix
        log_info "Обновляю имя пользователя в flake.nix..."
        sed -i "s/redm00us/$username/g" flake.nix
        log_success "flake.nix обновлен"
    else
        log_info "Имя пользователя не изменяется"
    fi

    # Настройка Git (если нужно)
    echo ""
    if confirm "Настроить Git конфигурацию?"; then
        read -p "Введите ваше имя для Git: " git_name
        read -p "Введите ваш email для Git: " git_email

        # Обновляем home.nix
        sed -i "s/userName = \"Redm00us\";/userName = \"$git_name\";/g" home/home.nix
        sed -i "s/userEmail = \"krokismau@icloud.com\";/userEmail = \"$git_email\";/g" home/home.nix
        log_success "Git конфигурация обновлена"
    fi
}

# ────────────── Настройка системы ──────────────
configure_system() {
    log_step "Настройка системы..."

    # Часовой пояс
    echo -e "${CYAN}Настройка часового пояса${NC}"
    local current_timezone
    current_timezone=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Europe/Moscow")
    echo "Текущий часовой пояс: $current_timezone"

    if confirm "Изменить часовой пояс? (текущий: $current_timezone)"; then
        echo "Примеры часовых поясов:"
        echo "  Europe/Moscow"
        echo "  Europe/Kiev"
        echo "  Europe/London"
        echo "  America/New_York"
        echo "  Asia/Tokyo"
        echo ""
        read -p "Введите часовой пояс: " timezone

        # Обновляем configuration.nix
        sed -i "s|time.timeZone = \".*\";|time.timeZone = \"$timezone\";|g" configuration.nix
        log_success "Часовой пояс обновлен: $timezone"
    fi

    # Локаль
    echo ""
    echo -e "${CYAN}Настройка локали${NC}"
    if confirm "Изменить локаль? (текущая: ru_UA.UTF-8)"; then
        echo "Примеры локалей:"
        echo "  en_US.UTF-8"
        echo "  ru_RU.UTF-8"
        echo "  uk_UA.UTF-8"
        echo ""
        read -p "Введите локаль: " locale

        # Обновляем configuration.nix
        sed -i "s|i18n.defaultLocale = \".*\";|i18n.defaultLocale = \"$locale\";|g" configuration.nix
        log_success "Локаль обновлена: $locale"
    fi
}

# ────────────── Сборка системы ──────────────
build_system() {
    log_step "Сборка и применение конфигурации..."

    echo -e "${YELLOW}Это может занять некоторое время...${NC}"
    echo ""

    # Проверяем flake
    log_info "Проверяю flake конфигурацию..."
    if ! nix flake check --no-build 2>/dev/null; then
        log_warning "Обнаружены проблемы с flake, но продолжаем..."
    fi

    # Собираем систему
    log_info "Собираю систему..."
    if sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure; then
        log_success "Система успешно собрана и применена!"
    else
        log_error "Ошибка при сборке системы!"
        echo ""
        log_info "Возможные решения:"
        echo "  1. Проверьте hardware-configuration.nix"
        echo "  2. Проверьте настройки в configuration.nix"
        echo "  3. Запустите: sudo nixos-rebuild switch --flake .#meowrch --show-trace"
        echo ""
        if confirm "Попробовать еще раз с подробным выводом?"; then
            sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure --show-trace
        else
            exit 1
        fi
    fi
}

# ────────────── Настройка Home Manager ──────────────
setup_home_manager() {
    log_step "Настройка Home Manager..."

    # Применяем конфигурацию Home Manager
    log_info "Применяю конфигурацию Home Manager..."
    if home-manager switch --flake .#$(whoami); then
        log_success "Home Manager успешно настроен!"
    else
        log_warning "Ошибка при настройке Home Manager"
        log_info "Попробуйте позже выполнить: home-manager switch --flake .#$(whoami)"
    fi
}

# ────────────── Пост-установка ──────────────
post_install() {
    log_step "Завершающие настройки..."

    # Добавляем Flathub (если нужно)
    if confirm "Добавить Flathub репозиторий для Flatpak?"; then
        log_info "Добавляю Flathub..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        log_success "Flathub добавлен"
    fi

    # Создаем важные директории
    log_info "Создаю пользовательские директории..."
    mkdir -p ~/.local/bin
    mkdir -p ~/.config/meowrch
    log_success "Директории созданы"

    # Проверяем систему
    log_info "Проверяю систему..."
    if command -v fastfetch &> /dev/null; then
        echo ""
        fastfetch
    fi
}

# ────────────── Главное меню ──────────────
main_menu() {
    while true; do
        show_logo
        echo -e "${WHITE}Выберите действие:${NC}"
        echo ""
        echo "  1) 🚀 Полная установка (рекомендуется)"
        echo "  2) ⚙️  Только проверка системы"
        echo "  3) 🔧 Настройка hardware-configuration.nix"
        echo "  4) 👤 Настройка пользователя"
        echo "  5) 🌍 Настройка системы (timezone, locale)"
        echo "  6) 🏗️  Сборка системы"
        echo "  7) 🏠 Настройка Home Manager"
        echo "  8) 📋 Показать информацию о системе"
        echo "  9) ❌ Выход"
        echo ""
        read -p "Введите номер (1-9): " choice

        case $choice in
            1)
                full_installation
                break
                ;;
            2)
                check_system
                read -p "Нажмите Enter для продолжения..."
                ;;
            3)
                setup_hardware_config
                read -p "Нажмите Enter для продолжения..."
                ;;
            4)
                configure_user
                read -p "Нажмите Enter для продолжения..."
                ;;
            5)
                configure_system
                read -p "Нажмите Enter для продолжения..."
                ;;
            6)
                build_system
                read -p "Нажмите Enter для продолжения..."
                ;;
            7)
                setup_home_manager
                read -p "Нажмите Enter для продолжения..."
                ;;
            8)
                show_system_info
                read -p "Нажмите Enter для продолжения..."
                ;;
            9)
                log_info "До свидания!"
                exit 0
                ;;
            *)
                log_error "Неверный выбор!"
                sleep 2
                ;;
        esac
    done
}

# ────────────── Полная установка ──────────────
full_installation() {
    show_logo
    echo -e "${WHITE}Начинаю полную установку NixOS 25.05 Meowrch...${NC}"
    echo ""

    if ! confirm "Продолжить полную установку?" "y"; then
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
    echo -e "${GREEN}║            🎉 УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА! 🎉                    ║${NC}"
    echo -e "${GREEN}║                                                                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Что дальше:${NC}"
    echo "  1. Перезагрузите систему: ${WHITE}sudo reboot${NC}"
    echo "  2. После перезагрузки войдите в Hyprland"
    echo "  3. Используйте алиасы Fish shell:"
    echo "     • ${WHITE}f${NC} - показать информацию о системе"
    echo "     • ${WHITE}c${NC} - открыть конфиг в Zed Editor"
    echo "     • ${WHITE}b${NC} - пересобрать систему"
    echo "     • ${WHITE}u${NC} - обновить и пересобрать"
    echo ""
    echo -e "${PURPLE}Горячие клавиши Hyprland:${NC}"
    echo "  • ${WHITE}Super + Enter${NC} - терминал"
    echo "  • ${WHITE}Super + D${NC} - меню приложений"
    echo "  • ${WHITE}Super + Alt + C${NC} - Zed Editor"
    echo "  • ${WHITE}Super + E${NC} - файловый менеджер"
    echo ""

    if confirm "Перезагрузить систему сейчас?" "y"; then
        log_info "Перезагружаю систему..."
        sudo reboot
    fi
}

# ────────────── Информация о системе ──────────────
show_system_info() {
    clear
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    ИНФОРМАЦИЯ О СИСТЕМЕ                          ║${NC}"
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
    echo -e "${CYAN}Статус конфигурации:${NC}"
    [[ -f hardware-configuration.nix ]] && echo "✓ hardware-configuration.nix найден" || echo "✗ hardware-configuration.nix отсутствует"
    [[ -f flake.nix ]] && echo "✓ flake.nix найден" || echo "✗ flake.nix отсутствует"
    [[ -f configuration.nix ]] && echo "✓ configuration.nix найден" || echo "✗ configuration.nix отсутствует"
    [[ -f home/home.nix ]] && echo "✓ home.nix найден" || echo "✗ home.nix отсутствует"

    echo ""
    echo -e "${CYAN}Доступные команды:${NC}"
    command -v nixos-rebuild >/dev/null && echo "✓ nixos-rebuild" || echo "✗ nixos-rebuild"
    command -v home-manager >/dev/null && echo "✓ home-manager" || echo "✗ home-manager"
    command -v nix >/dev/null && echo "✓ nix" || echo "✗ nix"
    command -v git >/dev/null && echo "✓ git" || echo "✗ git"
}

# ────────────── Обработка аргументов командной строки ──────────────
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
        echo "Использование: $0 [ОПЦИЯ]"
        echo ""
        echo "Опции:"
        echo "  --check     Проверить систему"
        echo "  --hardware  Настроить hardware-configuration.nix"
        echo "  --user      Настроить пользователя"
        echo "  --system    Настроить систему (timezone, locale)"
        echo "  --build     Собрать систему"
        echo "  --home      Настроить Home Manager"
        echo "  --full      Полная установка"
        echo "  --info      Показать информацию о системе"
        echo "  --help      Показать эту справку"
        echo ""
        echo "Без аргументов запускается интерактивное меню."
        ;;
    "")
        main_menu
        ;;
    *)
        log_error "Неизвестная опция: $1"
        echo "Используйте --help для справки."
        exit 1
        ;;
esac
