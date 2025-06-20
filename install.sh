#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Meowrch NixOS 25.05 Installer                        ║
# ║                         Обновленный установщик                           ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Логирование
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
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Проверка root прав
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Не запускайте этот скрипт от root!"
        log_info "Скрипт сам запросит sudo когда потребуется."
        exit 1
    fi
}

# Показать лого
show_logo() {
    clear
    echo -e "${CYAN}"
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

                            NixOS 25.05 Edition
                          🎯 Steam + Flatpack + Bluetooth
                          🚫 Без VS Code и NVIDIA
EOF
    echo -e "${NC}"
    echo
    log_info "Добро пожаловать в установщик Meowrch NixOS 25.05!"
    echo
}

# Проверка системы
check_system() {
    log_header "Проверка системы"

    # Проверка NixOS
    if [[ ! -f /etc/nixos/configuration.nix ]]; then
        log_error "Этот скрипт предназначен для NixOS!"
        exit 1
    fi

    # Проверка архитектуры
    if [[ $(uname -m) != "x86_64" ]]; then
        log_error "Поддерживается только x86_64 архитектура!"
        exit 1
    fi

    # Проверка интернета
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "Нет подключения к интернету!"
        exit 1
    fi

    log_success "Система готова к установке"
}

# Создание резервной копии
create_backup() {
    log_header "Создание резервной копии"

    local backup_dir="./backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # Копируем важные файлы
    if [[ -f /etc/nixos/configuration.nix ]]; then
        sudo cp /etc/nixos/configuration.nix "$backup_dir/"
        log_info "Скопирован configuration.nix"
    fi

    if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
        sudo cp /etc/nixos/hardware-configuration.nix "$backup_dir/"
        log_info "Скопирован hardware-configuration.nix"
    fi

    if [[ -f /etc/nixos/flake.nix ]]; then
        sudo cp /etc/nixos/flake.nix "$backup_dir/"
        log_info "Скопирован flake.nix"
    fi

    # Копируем пользовательские конфиги
    if [[ -d ~/.config ]]; then
        cp -r ~/.config "$backup_dir/user-config" 2>/dev/null || true
        log_info "Скопированы пользовательские конфиги"
    fi

    log_success "Резервная копия создана в $backup_dir"
}

# Копирование конфигурации
copy_configuration() {
    log_header "Копирование конфигурации Meowrch"

    # Копируем hardware-configuration.nix в наш конфиг
    if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
        sudo cp /etc/nixos/hardware-configuration.nix ./
        log_info "Скопирован hardware-configuration.nix"
    else
        log_error "hardware-configuration.nix не найден!"
        exit 1
    fi

    # Создаем директории
    sudo mkdir -p /etc/nixos

    # Копируем нашу конфигурацию
    sudo cp -r ./* /etc/nixos/
    sudo chown -R root:root /etc/nixos

    log_success "Конфигурация скопирована"
}

# Обновление каналов
update_channels() {
    log_header "Обновление каналов NixOS"

    # Обновляем каналы
    sudo nix-channel --update

    log_success "Каналы обновлены"
}

# Сборка системы
build_system() {
    log_header "Сборка системы NixOS 25.05"

    log_info "Начинаем сборку... Это может занять время."
    log_warning "Не прерывайте процесс сборки!"

    # Сборка конфигурации
    if sudo nixos-rebuild switch --flake /etc/nixos#meowrch; then
        log_success "Система успешно собрана!"
    else
        log_error "Ошибка при сборке системы!"
        log_info "Проверьте логи выше для получения подробностей."
        return 1
    fi
}

# Настройка пользователя
setup_user() {
    log_header "Настройка пользователя"

    local username="redm00us"

    # Проверяем существует ли пользователь
    if ! id "$username" &>/dev/null; then
        log_info "Создаем пользователя $username"
        sudo useradd -m -G wheel,networkmanager,audio,video,bluetooth "$username"
        sudo passwd "$username"
    else
        log_info "Пользователь $username уже существует"
        # Добавляем в нужные группы
        sudo usermod -a -G wheel,networkmanager,audio,video,bluetooth,render,docker,libvirtd "$username"
    fi

    log_success "Пользователь настроен"
}

# Включение сервисов
enable_services() {
    log_header "Включение системных сервисов"

    local services=(
        "NetworkManager"
        "bluetooth"
        "pipewire"
        "pipewire-pulse"
        "wireplumber"
        "flatpak"
    )

    for service in "${services[@]}"; do
        if sudo systemctl enable "$service" 2>/dev/null; then
            log_info "Включен сервис: $service"
        else
            log_warning "Не удалось включить сервис: $service (возможно уже включен)"
        fi
    done

    # Запускаем некоторые сервисы сразу
    local start_services=(
        "NetworkManager"
        "bluetooth"
    )

    for service in "${start_services[@]}"; do
        if sudo systemctl start "$service" 2>/dev/null; then
            log_info "Запущен сервис: $service"
        else
            log_warning "Не удалось запустить сервис: $service"
        fi
    done

    log_success "Сервисы настроены"
}

# Настройка Flatpak
setup_flatpak() {
    log_header "Настройка Flatpak"

    # Добавляем Flathub репозиторий
    if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
        log_info "Добавлен репозиторий Flathub"
    else
        log_warning "Репозиторий Flathub уже существует"
    fi

    # Устанавливаем базовые Flatpak приложения
    log_info "Установка базовых Flatpak приложений..."

    local flatpak_apps=(
        "org.mozilla.firefox"
        "com.github.tchx84.Flatseal"
        "org.gnome.Extensions"
    )

    for app in "${flatpak_apps[@]}"; do
        if flatpak install -y flathub "$app" 2>/dev/null; then
            log_info "Установлено: $app"
        else
            log_warning "Не удалось установить: $app"
        fi
    done

    log_success "Flatpak настроен"
}

# Проверка работоспособности
verify_installation() {
    log_header "Проверка установки"

    # Проверяем сервисы
    local critical_services=(
        "NetworkManager"
        "bluetooth"
        "pipewire"
    )

    local failed_services=()

    for service in "${critical_services[@]}"; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            log_success "✓ $service работает"
        else
            log_warning "✗ $service не работает"
            failed_services+=("$service")
        fi
    done

    # Проверяем Flatpak
    if command -v flatpak >/dev/null 2>&1; then
        log_success "✓ Flatpak установлен"
    else
        log_warning "✗ Flatpak не найден"
    fi

    # Проверяем Steam
    if command -v steam >/dev/null 2>&1; then
        log_success "✓ Steam установлен"
    else
        log_warning "✗ Steam не найден"
    fi

    # Проверяем Bluetooth
    if command -v bluetoothctl >/dev/null 2>&1; then
        log_success "✓ Bluetooth доступен"
    else
        log_warning "✗ Bluetooth не найден"
    fi

    if [[ ${#failed_services[@]} -gt 0 ]]; then
        log_warning "Некоторые сервисы требуют внимания после перезагрузки"
    else
        log_success "Все критические сервисы работают!"
    fi
}

# Финальные инструкции
show_final_instructions() {
    log_header "Установка завершена!"

    echo -e "${GREEN}🎉 Meowrch NixOS 25.05 успешно установлен!${NC}"
    echo
    echo -e "${CYAN}📋 Что было установлено:${NC}"
    echo "   ✅ Hyprland (Wayland композитор)"
    echo "   ✅ Steam (игровая платформа)"
    echo "   ✅ Flatpak (универсальные пакеты)"
    echo "   ✅ Bluetooth (беспроводная связь)"
    echo "   ✅ PipeWire (аудиосистема)"
    echo "   ✅ AMD GPU поддержка"
    echo
    echo -e "${CYAN}🚫 Что НЕ установлено:${NC}"
    echo "   ❌ VS Code (не нужен)"
    echo "   ❌ NVIDIA драйверы (не нужны)"
    echo
    echo -e "${YELLOW}📝 Следующие шаги:${NC}"
    echo "   1. Перезагрузите компьютер: ${WHITE}sudo reboot${NC}"
    echo "   2. Войдите как пользователь 'redm00us'"
    echo "   3. Запустите Hyprland из менеджера входа"
    echo "   4. Установите Flatpak приложения: ${WHITE}flatpak search <название>${NC}"
    echo "   5. Запустите Steam и настройте игры"
    echo
    echo -e "${CYAN}🔧 Полезные команды:${NC}"
    echo "   • Обновить систему: ${WHITE}sudo nixos-rebuild switch --flake /etc/nixos#meowrch${NC}"
    echo "   • Управление Bluetooth: ${WHITE}bluetoothctl${NC}"
    echo "   • Настройка звука: ${WHITE}pavucontrol${NC}"
    echo "   • Flatpak приложения: ${WHITE}flatpak list${NC}"
    echo
    echo -e "${PURPLE}💡 Документация: https://wiki.hyprland.org/${NC}"
    echo
}

# Основная функция
main() {
    show_logo

    # Проверка аргументов
    if [[ $# -gt 0 && "$1" == "--no-backup" ]]; then
        SKIP_BACKUP=true
    else
        SKIP_BACKUP=false
    fi

    check_root
    check_system

    # Подтверждение установки
    echo -e "${YELLOW}⚠️  Это установит Meowrch NixOS 25.05 конфигурацию.${NC}"
    echo -e "${YELLOW}   Ваша текущая конфигурация будет заменена.${NC}"
    echo
    read -p "Продолжить? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Установка отменена пользователем."
        exit 0
    fi

    # Создание резервной копии
    if [[ "$SKIP_BACKUP" != true ]]; then
        create_backup
    fi

    # Основной процесс установки
    {
        copy_configuration
        update_channels
        build_system
        setup_user
        enable_services
        setup_flatpak
        verify_installation
    } || {
        log_error "Установка не удалась!"
        log_info "Проверьте логи выше и попробуйте снова."
        exit 1
    }

    show_final_instructions

    # Предложение перезагрузки
    echo
    read -p "Перезагрузить сейчас? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Перезагрузка..."
        sudo reboot
    else
        log_info "Не забудьте перезагрузиться для применения всех изменений!"
    fi
}

# Обработка сигналов
trap 'log_error "Установка прервана пользователем"; exit 130' INT TERM

# Запуск
main "$@"
