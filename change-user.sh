#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                    Meowrch NixOS User Change Script                      ║
# ║                         Быстрая смена пользователя                       ║
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
NC='\033[0m'

# Функции логирования
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

# Показать использование
show_usage() {
    echo -e "${CYAN}Usage:${NC}"
    echo "  $0 [options]"
    echo
    echo -e "${CYAN}Options:${NC}"
    echo "  -u, --username     New username"
    echo "  -n, --name         Full name"
    echo "  -e, --email        Email address"
    echo "  -g, --git-name     Git name"
    echo "  -h, --help         Show this help"
    echo
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0 -u myuser -n \"My Name\" -e \"my@email.com\""
    echo "  $0 --username newuser --name \"New User\""
    echo "  $0  # Interactive mode"
    echo
}

# Валидация входных данных
validate_username() {
    local username="$1"
    if [[ ! "$username" =~ ^[a-z][a-z0-9_-]*$ ]]; then
        log_error "Username must start with lowercase letter and contain only lowercase letters, numbers, hyphens, and underscores"
        return 1
    fi
    return 0
}

validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Invalid email format"
        return 1
    fi
    return 0
}

validate_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[A-Za-z[:space:]]+$ ]]; then
        log_error "Name must contain only letters and spaces"
        return 1
    fi
    return 0
}

# Интерактивный ввод
prompt_input() {
    local prompt="$1"
    local default="$2"
    local validation_func="$3"
    local result=""

    while true; do
        echo -ne "${CYAN}$prompt${NC}"
        if [[ -n "$default" ]]; then
            echo -ne " ${YELLOW}(current: $default)${NC}"
        fi
        echo -n ": "

        read -r result

        # Использовать default если ввод пустой
        if [[ -z "$result" && -n "$default" ]]; then
            result="$default"
        fi

        # Валидация
        if [[ -n "$validation_func" ]]; then
            if "$validation_func" "$result"; then
                echo "$result"
                return 0
            fi
        else
            echo "$result"
            return 0
        fi
    done
}

# Поиск текущего пользователя в конфигурации
detect_current_user() {
    local current_user=""

    # Пытаемся найти пользователя в configuration.nix
    if [[ -f "configuration.nix" ]]; then
        current_user=$(grep -o 'users\.[a-z][a-z0-9_-]*' configuration.nix | head -1 | cut -d'.' -f2 2>/dev/null || echo "")
    fi

    # Если не найден, пытаемся найти в home.nix
    if [[ -z "$current_user" && -f "home/home.nix" ]]; then
        current_user=$(grep -o 'home\.username = "[^"]*"' home/home.nix | cut -d'"' -f2 2>/dev/null || echo "")
    fi

    # Если не найден, пытаемся найти в flake.nix
    if [[ -z "$current_user" && -f "flake.nix" ]]; then
        current_user=$(grep -o 'home-manager\.users\.[a-z][a-z0-9_-]*' flake.nix | head -1 | cut -d'.' -f3 2>/dev/null || echo "")
    fi

    echo "$current_user"
}

# Поиск текущих данных пользователя
detect_current_data() {
    local current_name=""
    local current_email=""
    local current_git_name=""

    if [[ -f "home/home.nix" ]]; then
        current_name=$(grep -o 'description = "[^"]*"' configuration.nix 2>/dev/null | cut -d'"' -f2 || echo "")
        current_email=$(grep -o 'userEmail = "[^"]*"' home/home.nix 2>/dev/null | cut -d'"' -f2 || echo "")
        current_git_name=$(grep -o 'userName = "[^"]*"' home/home.nix 2>/dev/null | cut -d'"' -f2 || echo "")
    fi

    echo "$current_name|$current_email|$current_git_name"
}

# Создание резервной копии
create_backup() {
    local backup_dir="./backup-user-change-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    local files=(
        "configuration.nix"
        "flake.nix"
        "home/home.nix"
        "home/modules/waybar.nix"
        "modules/system/security.nix"
    )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_dir/"
            log_info "Backed up: $file"
        fi
    done

    log_success "Backup created in: $backup_dir"
}

# Замена пользователя в файлах
replace_user_in_files() {
    local old_user="$1"
    local new_user="$2"
    local new_name="$3"
    local new_email="$4"
    local new_git_name="$5"

    log_header "Updating Configuration Files"

    local files=(
        "configuration.nix"
        "flake.nix"
        "home/home.nix"
        "home/modules/waybar.nix"
        "modules/system/security.nix"
    )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_info "Processing: $file"

            # Замены для configuration.nix
            if [[ "$file" == "configuration.nix" ]]; then
                sed -i "s/users\.$old_user/users.$new_user/g" "$file"
                if [[ -n "$new_name" ]]; then
                    sed -i "s/description = \"[^\"]*\"/description = \"$new_name\"/g" "$file"
                fi
            fi

            # Замены для flake.nix
            if [[ "$file" == "flake.nix" ]]; then
                sed -i "s/home-manager\.users\.$old_user/home-manager.users.$new_user/g" "$file"
                sed -i "s/$old_user = home-manager/\"$new_user\" = home-manager/g" "$file"
                sed -i "s/#$old_user\"/#$new_user\"/g" "$file"
            fi

            # Замены для home/home.nix
            if [[ "$file" == "home/home.nix" ]]; then
                # Основные настройки
                sed -i "s/home\.username = \"$old_user\"/home.username = \"$new_user\"/g" "$file"
                sed -i "s|home\.homeDirectory = \"/home/$old_user\"|home.homeDirectory = \"/home/$new_user\"|g" "$file"

                # Git настройки
                if [[ -n "$new_git_name" ]]; then
                    sed -i "s/userName = \"[^\"]*\"/userName = \"$new_git_name\"/g" "$file"
                fi
                if [[ -n "$new_email" ]]; then
                    sed -i "s/userEmail = \"[^\"]*\"/userEmail = \"$new_email\"/g" "$file"
                fi

                # Пути в алиасах и функциях
                sed -i "s|/home/$old_user/|/home/$new_user/|g" "$file"
                sed -i "s|\.#$old_user|.#$new_user|g" "$file"
            fi

            # Замены для home/modules/waybar.nix
            if [[ "$file" == "home/modules/waybar.nix" ]]; then
                sed -i "s|/home/$old_user/|/home/$new_user/|g" "$file"
            fi

            # Замены для modules/system/security.nix
            if [[ "$file" == "modules/system/security.nix" ]]; then
                sed -i "s/users = \\[ \"$old_user\" \\]/users = [ \"$new_user\" ]/g" "$file"
            fi

            log_success "✓ Updated: $file"
        else
            log_warning "⚠ Not found: $file"
        fi
    done
}

# Основная функция замены
change_user() {
    local new_username="$1"
    local new_name="$2"
    local new_email="$3"
    local new_git_name="$4"

    # Определяем текущего пользователя
    local current_user
    current_user=$(detect_current_user)

    if [[ -z "$current_user" ]]; then
        log_error "Could not detect current username in configuration"
        exit 1
    fi

    log_info "Current username: $current_user"
    log_info "New username: $new_username"

    if [[ "$current_user" == "$new_username" ]]; then
        log_warning "Username is the same, updating other fields only"
    fi

    # Создаем резервную копию
    create_backup

    # Выполняем замену
    replace_user_in_files "$current_user" "$new_username" "$new_name" "$new_email" "$new_git_name"

    log_success "User configuration updated successfully!"
    echo
    log_info "Next steps:"
    echo "  1. Review the changes in the configuration files"
    echo "  2. Run: ./validate-config.sh (to check for errors)"
    echo "  3. Run: sudo nixos-rebuild switch --flake .#meowrch"
    echo "  4. Run: home-manager switch --flake .#$new_username"
    echo "  5. Create/update the user account if needed"
}

# Интерактивный режим
interactive_mode() {
    log_header "Interactive User Configuration"

    # Определяем текущие данные
    local current_user
    current_user=$(detect_current_user)

    local current_data
    current_data=$(detect_current_data)
    IFS='|' read -r current_name current_email current_git_name <<< "$current_data"

    if [[ -n "$current_user" ]]; then
        log_info "Current configuration detected:"
        echo "  Username: $current_user"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
        echo "  Git Name: $current_git_name"
        echo
    fi

    # Ввод новых данных
    local new_username
    new_username=$(prompt_input "New username" "$current_user" "validate_username")

    local new_name
    new_name=$(prompt_input "Full name" "$current_name" "validate_name")

    local new_email
    new_email=$(prompt_input "Email address" "$current_email" "validate_email")

    local new_git_name
    new_git_name=$(prompt_input "Git name" "$new_name" "validate_name")

    echo
    log_info "Configuration summary:"
    echo "  Username: $new_username"
    echo "  Name: $new_name"
    echo "  Email: $new_email"
    echo "  Git Name: $new_git_name"
    echo

    read -p "Proceed with these changes? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled"
        exit 0
    fi

    change_user "$new_username" "$new_name" "$new_email" "$new_git_name"
}

# Основная функция
main() {
    # Проверяем, что мы в правильной директории
    if [[ ! -f "flake.nix" ]] || [[ ! -f "configuration.nix" ]]; then
        log_error "This script must be run from the Meowrch NixOS configuration directory"
        exit 1
    fi

    # Переменные для аргументов
    local username=""
    local name=""
    local email=""
    local git_name=""

    # Обработка аргументов
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--username)
                username="$2"
                shift 2
                ;;
            -n|--name)
                name="$2"
                shift 2
                ;;
            -e|--email)
                email="$2"
                shift 2
                ;;
            -g|--git-name)
                git_name="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Если аргументы не переданы, запускаем интерактивный режим
    if [[ -z "$username" && -z "$name" && -z "$email" && -z "$git_name" ]]; then
        interactive_mode
        return
    fi

    # Валидация обязательных параметров
    if [[ -z "$username" ]]; then
        log_error "Username is required when using non-interactive mode"
        show_usage
        exit 1
    fi

    # Валидация входных данных
    validate_username "$username"

    if [[ -n "$name" ]]; then
        validate_name "$name"
    fi

    if [[ -n "$email" ]]; then
        validate_email "$email"
    fi

    if [[ -n "$git_name" ]]; then
        validate_name "$git_name"
    fi

    # Выполняем замену
    change_user "$username" "$name" "$email" "$git_name"
}

# Обработка сигналов
trap 'log_error "Operation interrupted"; exit 130' INT TERM

# Запуск
main "$@"
