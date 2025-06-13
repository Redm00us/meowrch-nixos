# 🐱 Оптимизированная NixOS 25.05 Конфигурация ≽ܫ≼

![NixOS Logo](https://nixos.org/logo/nixos-logo-only-hires.png)

Оптимизированная конфигурация NixOS 25.05 с Hyprland, основанная на проекте NixOS-Meowrch. Включает в себя последние пакеты, Zen Browser, Yandex Music, Spicetify с темой Catppuccin и множество улучшений производительности.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🌟 Обзор

Эта оптимизированная конфигурация NixOS 25.05 предоставляет:
- **Hyprland** как основной Wayland композитор
- **Zen Browser** - современный браузер с автосборкой
- **Yandex Music** - неофициальный клиент с автообновлениями
- **Spicetify** с темой Catppuccin Mocha для Spotify
- **Zed Editor** из нестабильного канала
- **Kitty** терминал с поддержкой GPU
- **Fish** shell с умными алиасами
- **Zed Editor** с настроенной конфигурацией
- **Catppuccin** тема для всей системы
- **Flatpak** поддержка для дополнительных приложений
- **Home Manager** для пользовательских настроек

## ✨ Features

### ✨ Ключевые особенности

#### 🎨 Рабочая среда
- **Hyprland**: Последний стабильный Wayland композитор
- **SDDM**: Менеджер входа с поддержкой Wayland
- **Catppuccin Mocha**: Единая тема для всей системы

#### 🛠️ Приложения
- **Zen Browser**: Современный браузер (автосборка из unstable)
- **Yandex Music**: Неофициальный клиент (автосборка)
- **Zed Editor**: Быстрый редактор кода (unstable)
- **Zed Editor**: Быстрый современный редактор кода
- **Kitty**: GPU-терминал с JetBrainsMono Nerd Font
- **Spotify** с Spicetify и темой Catppuccin

#### 🎯 Системные возможности
- **NixOS 25.05**: Стабильная база с overlay для fresh пакетов
- **Flake**: Воспроизводимая конфигурация
- **Home Manager**: Управление пользовательскими настройками
- **Flatpak**: Поддержка дополнительных приложений
- **AMD/Intel/NVIDIA**: Поддержка всех типов GPU
- **Gaming**: Steam, GameMode, MangoHUD
- **Разработка**: Python 3.11, Node.js, клиенты Git

#### 🔧 Оптимизации
- **Умные алиасы**: Быстрые команды для управления системой
- **Автообновления**: Zen Browser и Yandex Music
- **Производительность**: Оптимизированные настройки GPU
- **Безопасность**: GNOME Keyring, Polkit настройки

## 📋 Requirements

### Hardware
- **CPU**: x86_64 processor (Intel/AMD)
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: 20GB minimum, 50GB+ recommended
- **Graphics**: Any GPU (Intel/AMD/NVIDIA supported)

### Software
- Fresh NixOS installation (25.05 or later)
- Git for cloning the repository
- Internet connection for package downloads

## 🚀 Installation

### 🎯 Быстрая установка (Рекомендуется)

```bash
# 1. Клонируем репозиторий
git clone https://github.com/Redm00use/NixOS-Meowrch.git NixOS-25.05
cd NixOS-25.05

# 2. Запускаем умный установщик
./install.sh
```

**Или для полностью автоматической установки:**

```bash
# Автоматическая установка без интерактивного меню
./install.sh --full
```

### 🔧 Ручная установка (для продвинутых пользователей)

<details>
<summary>Нажмите для развертывания инструкций по ручной установке</summary>

#### 1. Клонирование репозитория

```bash
git clone https://github.com/Redm00use/NixOS-Meowrch.git NixOS-25.05
cd NixOS-25.05
```

#### 2. Конфигурация оборудования

```bash
# Копируем hardware-configuration.nix
sudo cp /etc/nixos/hardware-configuration.nix .

# Или генерируем новый (если отсутствует)
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

#### 3. Настройка конфигурации

Отредактируйте файлы под вашу систему:
- Имя пользователя (по умолчанию: `redm00us`)
- Часовой пояс (по умолчанию: `Europe/Moscow`)
- Git настройки в `home/home.nix`

#### 4. Сборка и применение

```bash
# Собираем систему
sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure

# Применяем Home Manager
home-manager switch --flake .#имя_пользователя

# Перезагружаемся
sudo reboot
```

</details>

### 📋 Возможности установщика

Умный установщик `install.sh` предоставляет:

**🎮 Интерактивный режим:**
- Красивое ASCII лого и меню
- Пошаговая настройка системы
- Автоматическая диагностика проблем
- Проверка совместимости

**⚡ Быстрые команды:**
```bash
./install.sh --check    # Проверить систему
./install.sh --hardware # Настроить hardware-configuration.nix  
./install.sh --user     # Настроить пользователя
./install.sh --build    # Собрать систему
./install.sh --home     # Настроить Home Manager
./install.sh --info     # Показать информацию о системе
./install.sh --help     # Справка
```

**🔧 Автоматические настройки:**
- Копирование `hardware-configuration.nix`
- Настройка имени пользователя во всех файлах
- Конфигурация Git (имя, email)
- Настройка часового пояса и локали
- Добавление Flathub репозитория
- Проверка зависимостей

### 🎉 После установки

После перезагрузки система будет готова к работе с:
- Hyprland как основной рабочей средой
- Zed Editor настроенным с темой Catppuccin
- Всеми удобными алиасами Fish shell
- Zen Browser и Yandex Music
- Spotify с кастомной темой Spicetify

## ⚙️ Конфигурация

### Управление пользователями

Чтобы изменить имя пользователя с `redm00us`:

1. Отредактируйте `configuration.nix`:
```nix
users.users.YOUR_USERNAME = {
  isNormalUser = true;
  description = "Your Description";
  extraGroups = [ "wheel" "networkmanager" /* ... */ ];
  shell = pkgs.fish;
};
```

2. Отредактируйте `home/home.nix`:
```nix
home.username = "YOUR_USERNAME";
home.homeDirectory = "/home/YOUR_USERNAME";
```

3. Обновите flake.nix:
```nix
home-manager.users.YOUR_USERNAME = {
  # ...
};
```

### Graphics Drivers

The configuration automatically detects and configures graphics drivers. For manual override:

```nix
# In configuration.nix
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
  
  # For NVIDIA users
  extraPackages = with pkgs; [ nvidia-vaapi-driver ];
};
```

### Monitor Configuration

Edit `home/modules/hyprland.nix` to configure your monitors:

```nix
monitor = [
  "DP-1,1920x1080@144,0x0,1"
  "HDMI-1,1920x1080@60,1920x0,1"
  # Add more monitors as needed
];
```

## 🎮 Usage

### Keyboard Shortcuts

| Действие | Сочетание клавиш |
|----------|------------------|
| Открыть терминал | `Super + Enter` |
| Запуск приложений | `Super + D` |
| Файловый менеджер | `Super + E` |
| Открыть Zed Editor | `Super + Alt + C` |
| Скриншот | `Print Screen` |
| Заблокировать экран | `Super + L` |
| Закрыть окно | `Super + Q` |
| Плавающий режим | `Super + Space` |
| Полный экран | `Alt + Enter` |
| Переключить рабочий стол | `Super + 1-10` |
| Переместить окно | `Super + Shift + 1-10` |
| Громкость +/- | `XF86AudioRaiseVolume/LowerVolume` |
| Яркость +/- | `XF86MonBrightnessUp/Down` |

### Удобные алиасы Fish Shell

Конфигурация включает множество полезных алиасов:

```bash
# Быстрые команды системы
b          # Пересобрать систему
u          # Обновить флейк и пересобрать
c          # Открыть конфиг в Zed Editor
f          # Показать информацию о системе
dell       # Очистить мусор Nix
hm         # Применить Home Manager

# Git сокращения
g          # git
gs         # git status
ga         # git add
gc         # git commit
gp         # git push

# Файловая система
ll, la, l  # ls варианты
..         # cd ..
...        # cd ../..
cls        # clear
```

### Настройка Zed Editor

Zed настроен с темой Catppuccin Mocha и включает:

**Основные возможности:**
- Тема Catppuccin Mocha для единообразия с системой
- Шрифт JetBrainsMono Nerd Font
- Поддержка Nix с LSP (nil) и форматтером (alejandra)
- Автосохранение и форматирование при сохранении
- Git интеграция с inline blame

**Горячие клавиши Zed:**
```bash
Ctrl + /           # Переключить комментарии
Ctrl + D           # Выбрать следующее вхождение
Ctrl + Shift + K   # Удалить строку
Ctrl + Shift + D   # Дублировать строку
Ctrl + P           # Быстрый поиск файлов
Ctrl + Shift + P   # Палитра команд
Ctrl + Shift + F   # Поиск и замена
Ctrl + `           # Переключить терминал
```

**Настройка языков:**
- Nix: автоматическое форматирование с alejandra
- Git: встроенная интеграция
- Поддержка множества языков программирования

### Theme Management

```bash
# List available themes
python ~/.config/meowrch/meowrch.py --action list-themes

# Apply a theme
python ~/.config/meowrch/meowrch.py --action select-theme

# Change wallpaper
python ~/.config/meowrch/meowrch.py --action select-wallpaper
```

## 🎨 Customization

### Adding New Packages

#### Системные пакеты
Добавьте в `modules/packages/packages.nix`:
```nix
environment.systemPackages = with pkgs; [
  # Ваши пакеты здесь
  neovim
  discord
  telegram-desktop
];
```

#### Пользовательские пакеты
Добавьте в `home/home.nix`:
```nix
home.packages = with pkgs; [
  # Ваши пакеты здесь
  gimp
  blender
  obs-studio
];
```

#### Flatpak приложения
```bash
# Установка через Flatpak
flatpak install flathub org.telegram.desktop
flatpak install flathub com.discordapp.Discord
```

### Creating Custom Themes

1. Create theme directory:
```bash
mkdir -p ~/.local/share/themes/MyTheme
```

2. Add theme files (GTK, Qt, etc.)

3. Register with theme manager:
```bash
python ~/.config/meowrch/meowrch.py --action add-theme MyTheme
```

### Modifying Waybar

Edit `home/modules/waybar.nix` to customize the status bar:
- Add new modules
- Change colors and styling
- Modify layout and positioning

### Custom Keybindings

Edit `home/modules/hyprland.nix` to add or modify keybindings:
```nix
bind = [
  # Your custom bindings
  "$mainMod, Y, exec, your-command"
];
```

## 🔧 Troubleshooting

### Проблемы с установщиком

#### 🚫 "Этот скрипт должен запускаться на NixOS!"
```bash
# Убедитесь, что вы запускаете на NixOS
cat /etc/NIXOS  # Файл должен существовать

# Если вы на другой системе, сначала установите NixOS
```

#### 🔐 Проблемы с правами sudo
```bash
# Добавьте пользователя в группу wheel
sudo usermod -aG wheel $USER

# Или настройте sudo вручную
sudo visudo
```

#### 📁 "hardware-configuration.nix не найден"
```bash
# Сгенерируйте hardware-configuration.nix
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Или скопируйте из системы
sudo cp /etc/nixos/hardware-configuration.nix .
```

#### ⚠️ Ошибки при сборке flake
```bash
# Инициализируйте Git репозиторий
git init
git add .
git commit -m "Initial commit"

# Проверьте flake
nix flake check --no-build
```

### Системные проблемы

#### 1. Ошибки сборки системы
```bash
# Очистите кэш
sudo nix-collect-garbage -d
nix-collect-garbage -d

# Обновите flake
nix flake update

# Пересоберите с подробным выводом
sudo nixos-rebuild switch --flake .#meowrch --show-trace
```

#### 2. Проблемы с графикой
```bash
# Проверьте драйверы
lspci | grep VGA
glxinfo | grep vendor

# Для NVIDIA проверьте загрузку драйверов
lsmod | grep nvidia

# Для AMD проверьте
lsmod | grep amdgpu
```

#### 3. Проблемы со звуком
```bash
# Проверьте PipeWire
systemctl --user status pipewire
systemctl --user status wireplumber

# Перезапустите аудио
systemctl --user restart pipewire pipewire-pulse wireplumber
```

#### 4. Проблемы с Home Manager
```bash
# Проверьте конфигурацию
home-manager switch --flake .#$(whoami)

# Посмотрите новости Home Manager
home-manager news

# Сбросьте конфигурацию
home-manager switch --flake .#$(whoami) --recreate-lock-file
```

#### 5. Проблемы с Hyprland
```bash
# Проверьте логи Hyprland
cat ~/.cache/hyprland/hyprland.log

# Проверьте конфигурацию
hyprctl monitors
hyprctl workspaces
```

### Полезные команды для диагностики

```bash
# Информация о системе
./install.sh --info

# Проверка системы
./install.sh --check

# Системные логи
journalctl -xe

# Логи последнего boot
journalctl -b

# Проверка статуса сервисов
systemctl status
systemctl --user status

# Проверка места на диске
df -h
nix-store --gc --print-roots | head -20
```

### Если ничего не помогает

1. **Восстановите предыдущую конфигурацию:**
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

2. **Создайте issue с информацией:**
   - Версия NixOS: `nixos-version`
   - Тип GPU: `lspci | grep VGA`
   - Ошибки из `journalctl -xe`
   - Вывод `./install.sh --info`

3. **Попробуйте минимальную установку:**
   ```bash
   # Временно отключите сложные модули
   # и соберите базовую систему
   ```

## 🔄 Updates

### Обновление системы

```bash
# Используйте удобный алиас
u          # Обновить флейк и пересобрать систему

# Или полные команды:
cd ~/NixOS-25.05
nix flake update
sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure
home-manager switch --flake .#redm00us
```

### Updating Individual Packages

```bash
# Update specific package from unstable
nix shell nixpkgs#package-name

# Add to unstable overlay in configuration
```

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Environment

```bash
# Enter development shell
nix develop

# Available commands will be shown
```

## 📚 Ресурсы

- [Оригинальный проект NixOS-Meowrch](https://github.com/Redm00use/NixOS-Meowrch)
- [Документация NixOS](https://nixos.org/manual/nixos/stable/)
- [Документация Home Manager](https://nix-community.github.io/home-manager/)
- [Wiki Hyprland](https://wiki.hyprland.org/)
- [Catppuccin Theme](https://github.com/catppuccin)
- [Zen Browser](https://zen-browser.app/)
- [Spicetify](https://spicetify.app/)

## 🔧 Поддержка

Если у вас возникли проблемы:

1. Проверьте логи: `journalctl -xe`
2. Проверьте статус Home Manager: `home-manager news`
3. Очистите кеш: `dell` (алиас для очистки)
4. Пересоберите систему: `b` (алиас для rebuild)

## ⭐ Особенности этой версии

- ✅ Оптимизирована для NixOS 25.05
- ✅ Исправлены устаревшие параметры
- ✅ Добавлена поддержка Flatpak
- ✅ Интеграция Zen Browser и Yandex Music
- ✅ Spicetify с темой Catppuccin
- ✅ Улучшенные алиасы для Fish Shell
- ✅ Настроенный Zed Editor с темой Catppuccin
- ✅ Автоматические обновления пакетов unstable

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- **Meowrch Team**: For the original beautiful rice
- **NixOS Community**: For the amazing package manager and OS
- **Hyprland Developers**: For the excellent Wayland compositor
- **Catppuccin Team**: For the beautiful color schemes
- **All Contributors**: Who help make this project better

---

**Создано с ❤️ на основе проекта Redm00us**

*Если вам нравится эта конфигурация, поставьте звезду репозиторию и поделитесь с друзьями!*

## 🎯 Быстрый старт

### ⚡ Автоматическая установка (1 команда)

```bash
# Клонируем и запускаем умный установщик
git clone https://github.com/Redm00use/NixOS-Meowrch.git NixOS-25.05
cd NixOS-25.05
./install.sh --full
```

### 🎮 Интерактивная установка (рекомендуется)

```bash
# Клонируем репозиторий
git clone https://github.com/Redm00use/NixOS-Meowrch.git NixOS-25.05
cd NixOS-25.05

# Запускаем интерактивный установщик
./install.sh

# Выбираем: 1) 🚀 Полная установка
# Следуем инструкциям на экране
# Перезагружаемся после завершения
```

### 🔧 Ручная установка (для экспертов)

```bash
# Клонируем и настраиваем
git clone https://github.com/Redm00use/NixOS-Meowrch.git NixOS-25.05
cd NixOS-25.05

# Копируем hardware-configuration.nix
sudo cp /etc/nixos/hardware-configuration.nix .

# Изменяем пользователя (если нужно)
sed -i 's/redm00us/ваш_пользователь/g' configuration.nix home/home.nix flake.nix

# Собираем систему
sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure

# Настраиваем Home Manager
home-manager switch --flake .#ваш_пользователь

# Перезагружаемся
sudo reboot
```

**🎉 После установки используйте удобные алиасы:**
- `f` - показать fastfetch
- `c` - открыть конфиг в Zed
- `b` - пересобрать систему
- `u` - обновить и пересобрать