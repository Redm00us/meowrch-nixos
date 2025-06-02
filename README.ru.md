# 🐱 Meowrch NixOS Конфигурация ≽ܫ≼

![Meowrch Logo](https://raw.githubusercontent.com/meowrch/meowrch/main/.meta/logo.png)

Красивая, оптимизированная для производительности NixOS конфигурация, основанная на Meowrch Arch Linux rice, включающая Hyprland с кастомными темами, скриптами и полноценным рабочим окружением.

## 📋 Содержание

- [Обзор](#обзор)
- [Особенности](#особенности)
- [Требования](#требования)
- [Установка](#установка)
- [Конфигурация](#конфигурация)
- [Использование](#использование)
- [Кастомизация](#кастомизация)
- [Решение проблем](#решение-проблем)
- [Участие в разработке](#участие-в-разработке)

## 🌟 Обзор

Эта NixOS конфигурация воссоздает полный опыт рабочего стола Meowrch на стабильной NixOS 25.05, предоставляя:
- **Hyprland** как основной Wayland композитор
- **Waybar** с кастомными модулями и красивой стилизацией
- **Kitty** терминал с темой Catppuccin
- **Fish** shell с кастомными функциями и алиасами
- **Rofi** лаунчер приложений с кастомными меню
- Полную **систему управления темами**
- **Кастомные скрипты** для управления системой
- Интеграцию **Home Manager** для пользовательских конфигураций

## ✨ Особенности

### 🎨 Рабочее окружение
- **Hyprland**: Последний стабильный Wayland композитор с эффектами размытия и анимациями
- **Waybar**: Высоко настроенная панель состояния с мониторингом системы
- **Rofi**: Красивый лаунчер приложений с меню питания, выбором эмодзи и многим другим
- **Dunst**: Демон уведомлений с кастомной стилизацией
- **SDDM**: Менеджер входа с поддержкой Wayland

### 🛠️ Приложения и инструменты
- **Kitty**: GPU-ускоренный терминал с JetBrainsMono Nerd Font
- **Fish**: Современный shell с кастомными функциями и starship prompt
- **Firefox**: Веб-браузер с настройками приватности
- **VSCode**: Среда разработки
- **Nemo**: Файловый менеджер
- **Кастомные скрипты**: Громкость, яркость, скриншоты, пипетка цветов и многое другое

### 🎯 Системные особенности
- **Стабильная NixOS 25.05**: Надежная база с unstable overlay для отдельных пакетов
- **На основе Flake**: Воспроизводимая и декларативная конфигурация
- **Home Manager**: Управление пакетами и конфигурацией на уровне пользователя
- **Драйверы графики**: Поддержка Intel, AMD и NVIDIA
- **Игры**: Поддержка Steam, GameMode, MangoHUD
- **Разработка**: Python, Node.js, Rust, Go и многое другое

### 🎭 Темы
- **Catppuccin**: Красивая цветовая схема по всей системе
- **Кастомный Waybar**: Стилизован под оригинальную эстетику Meowrch
- **GTK/Qt**: Согласованные темы во всех приложениях
- **Иконки**: Тема иконок Papirus с темными вариантами
- **Курсоры**: Тема курсоров Bibata
- **Обои**: Кураторская коллекция красивых фонов

## 📋 Требования

### Аппаратное обеспечение
- **CPU**: x86_64 процессор (Intel/AMD)
- **RAM**: Минимум 4GB, рекомендуется 8GB+
- **Хранилище**: Минимум 20GB, рекомендуется 50GB+
- **Графика**: Любая GPU (поддерживается Intel/AMD/NVIDIA)

### Программное обеспечение
- Свежая установка NixOS (25.05 или новее)
- Git для клонирования репозитория
- Интернет-соединение для загрузки пакетов

## 🚀 Установка

### Быстрая установка

```bash
# Клонируйте репозиторий
git clone https://github.com/meowrch/meowrch.git
cd meowrch/NixOS-25.05

# Запустите интерактивный скрипт установки
./install.sh
```

### Ручная установка

#### 1. Клонирование репозитория

```bash
git clone https://github.com/meowrch/meowrch.git
cd meowrch/NixOS-25.05
```

#### 2. Конфигурация оборудования

Скопируйте существующую конфигурацию оборудования:

```bash
# Скопируйте из текущей установки NixOS
sudo cp /etc/nixos/hardware-configuration.nix .
```

Или сгенерируйте новую:

```bash
# Сгенерируйте конфигурацию оборудования
sudo nixos-generate-config --root /mnt --show-hardware-config > hardware-configuration.nix
```

#### 3. Настройка конфигурации

Отредактируйте основные конфигурационные файлы под вашу систему:

```bash
# Отредактируйте пользовательские настройки
nano configuration.nix

# Настройте home manager
nano home/home.nix
```

Ключевые параметры для настройки:
- Имя пользователя в `configuration.nix` и `home/home.nix`
- Часовой пояс в `configuration.nix`
- Конфигурация мониторов в `home/modules/hyprland.nix`
- Сетевые настройки при необходимости

#### 4. Сборка и переключение

```bash
# Соберите конфигурацию
sudo nixos-rebuild switch --flake .#meowrch

# Перезагрузитесь для применения всех изменений
sudo reboot
```

#### 5. Настройка после установки

После перезагрузки войдите в систему и выполните:

```bash
# Примените конфигурацию home manager
home-manager switch --flake .#meowrch

# Настройте темы и обои
python ~/.config/meowrch/meowrch.py --action set-current-theme
python ~/.config/meowrch/meowrch.py --action set-wallpaper
```

## ⚙️ Конфигурация

### Управление пользователями

Чтобы изменить имя пользователя с `meowrch`:

1. Отредактируйте `configuration.nix`:
```nix
users.users.YOUR_USERNAME = {
  # ... конфигурация пользователя
};
```

2. Отредактируйте `home/home.nix`:
```nix
home = {
  username = "YOUR_USERNAME";
  homeDirectory = "/home/YOUR_USERNAME";
  # ...
};
```

3. Обновите ссылки в flake.nix при необходимости.

### Графические драйверы

Конфигурация автоматически определяет и настраивает графические драйверы. Для ручной настройки:

```nix
# В configuration.nix
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
  
  # Для пользователей NVIDIA
  extraPackages = with pkgs; [ nvidia-vaapi-driver ];
};

# Для AMD GPU (уже настроено по умолчанию)
services.xserver.videoDrivers = [ "amdgpu" ];
boot.kernelParams = [
  "amdgpu.ppfeaturemask=0xffffffff"
  "amdgpu.gpu_recovery=1"
  "amdgpu.dc=1"
];
```

### Конфигурация мониторов

Отредактируйте `home/modules/hyprland.nix` для настройки ваших мониторов:

```nix
monitor = [
  "DP-1,1920x1080@144,0x0,1"
  "HDMI-1,1920x1080@60,1920x0,1"
  # Добавьте больше мониторов по необходимости
];
```

### Bluetooth

Bluetooth настроен и готов к использованию:

```bash
# Включить Bluetooth
bluetoothctl power on

# Сканировать устройства
bluetoothctl scan on

# Подключить устройство
bluetoothctl connect [MAC_ADDRESS]

# Или используйте GUI
blueman-manager
```

## 🎮 Использование

### Горячие клавиши

| Действие | Горячая клавиша Hyprland |
|----------|-------------------------|
| Открыть терминал | `Super + Enter` |
| Открыть лаунчер приложений | `Super + D` |
| Открыть файловый менеджер | `Super + E` |
| Сделать скриншот | `Print Screen` |
| Заблокировать экран | `Super + L` |
| Сменить обои | `Super + W` |
| Сменить тему | `Super + T` |
| Громкость вверх/вниз | `XF86AudioRaiseVolume/LowerVolume` |
| Яркость вверх/вниз | `XF86MonBrightnessUp/Down` |
| Закрыть окно | `Super + Q` |
| Переключить плавающий режим | `Super + Space` |
| Полноэкранный режим | `Alt + Enter` |
| Переключить рабочий стол | `Super + 1-10` |
| Переместить окно на рабочий стол | `Super + Shift + 1-10` |

### Кастомные скрипты

Конфигурация включает множество кастомных скриптов:

```bash
# Управление громкостью
~/bin/volume.sh --help

# Управление яркостью
~/bin/brightness.sh --help

# Пипетка цветов
~/bin/color-picker.sh

# Информация о системе
~/bin/system-info.py --help

# Управление темами
python ~/.config/meowrch/meowrch.py --help
```

### Управление темами

```bash
# Список доступных тем
python ~/.config/meowrch/meowrch.py --action list-themes

# Применить тему
python ~/.config/meowrch/meowrch.py --action select-theme

# Сменить обои
python ~/.config/meowrch/meowrch.py --action select-wallpaper
```

### Bluetooth

```bash
# Включить/выключить Bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Использовать GUI менеджер
blueman-manager

# Командная строка
bluetoothctl
```

## 🎨 Кастомизация

### Добавление новых пакетов

#### Системные пакеты
Добавьте в `configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  # Ваши пакеты здесь
  neovim
  discord
];
```

#### Пользовательские пакеты
Добавьте в `home/home.nix`:
```nix
home.packages = with pkgs; [
  # Ваши пакеты здесь
  spotify
  gimp
];
```

### Создание кастомных тем

1. Создайте директорию темы:
```bash
mkdir -p ~/.local/share/themes/MyTheme
```

2. Добавьте файлы темы (GTK, Qt и т.д.)

3. Зарегистрируйте в менеджере тем:
```bash
python ~/.config/meowrch/meowrch.py --action add-theme MyTheme
```

### Модификация Waybar

Отредактируйте `home/modules/waybar.nix` для настройки панели состояния:
- Добавьте новые модули
- Измените цвета и стилизацию
- Модифицируйте макет и позиционирование

### Кастомные горячие клавиши

Отредактируйте `home/modules/hyprland.nix` для добавления или изменения горячих клавиш:
```nix
bind = [
  # Ваши кастомные привязки
  "$mainMod, Y, exec, your-command"
];
```

## 🔧 Решение проблем

### Частые проблемы

#### 1. Ошибки сборки
```bash
# Очистить кэш сборки
sudo nix-collect-garbage -d

# Обновить входы flake
nix flake update

# Пересобрать
sudo nixos-rebuild switch --flake .#meowrch
```

#### 2. Проблемы с графикой
```bash
# Проверить графические драйверы
lspci | grep VGA
glxinfo | grep vendor

# Для пользователей NVIDIA убедитесь, что драйверы загружены
lsmod | grep nvidia

# Для AMD пользователей
lsmod | grep amdgpu
```

#### 3. Проблемы с аудио
```bash
# Проверить аудио сервисы
systemctl --user status pipewire

# Перезапустить аудио
systemctl --user restart pipewire pipewire-pulse
```

#### 4. Проблемы с Bluetooth
```bash
# Проверить статус Bluetooth
systemctl status bluetooth

# Перезапустить Bluetooth
sudo systemctl restart bluetooth

# Проверить подключенные устройства
bluetoothctl devices
```

#### 5. Проблемы Home Manager
```bash
# Сбросить home manager
home-manager switch --flake .#meowrch

# Проверить конфликты
home-manager news
```

### Логи и отладка

```bash
# Системные логи
journalctl -xe

# Логи Hyprland
cat ~/.cache/hyprland/hyprland.log

# Логи Home manager
home-manager news
```

## 🔄 Обновления

### Обновление системы

```bash
# Обновить входы flake
nix flake update

# Пересобрать систему
sudo nixos-rebuild switch --flake .#meowrch

# Обновить home manager
home-manager switch --flake .#meowrch
```

### Обновление отдельных пакетов

```bash
# Обновить конкретный пакет из unstable
nix shell nixpkgs#package-name

# Добавить в unstable overlay в конфигурации
```

## 🤝 Участие в разработке

Мы приветствуем вклад в развитие! Пожалуйста:

1. Сделайте fork репозитория
2. Создайте ветку для функции
3. Внесите изменения
4. Тщательно протестируйте
5. Отправьте pull request

### Среда разработки

```bash
# Войти в среду разработки
nix develop

# Доступные команды будут показаны
```

## 📚 Ресурсы

- [Оригинальный проект Meowrch](https://github.com/meowrch/meowrch)
- [Руководство NixOS](https://nixos.org/manual/nixos/stable/)
- [Руководство Home Manager](https://nix-community.github.io/home-manager/)
- [Wiki Hyprland](https://wiki.hyprland.org/)
- [Тема Catppuccin](https://github.com/catppuccin)

## 📄 Лицензия

Этот проект лицензирован под лицензией MIT - см. файл [LICENSE](../LICENSE) для деталей.

## 🙏 Благодарности

- **Команде Meowrch**: За оригинальный красивый rice
- **Сообществу NixOS**: За потрясающий пакетный менеджер и ОС
- **Разработчикам Hyprland**: За отличный Wayland композитор
- **Команде Catppuccin**: За красивые цветовые схемы
- **Всем участникам**: Кто помогает сделать этот проект лучше

---

**Сделано с ❤️ сообществом Meowrch**

*Если вам нравится эта конфигурация, пожалуйста, поставьте звезду репозиторию и поделитесь с другими!*

## 🔧 Специальные настройки для AMD GPU и Bluetooth

### AMD GPU оптимизация

Ваша конфигурация уже оптимизирована для AMD GPU:

```bash
# Проверить статус AMD GPU
lspci | grep VGA
radeontop  # мониторинг GPU

# Переменные окружения для AMD
export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi
export AMD_VULKAN_ICD=RADV
```

### Bluetooth продвинутые настройки

```bash
# Настройка качества аудио Bluetooth
bluetoothctl
# В bluetoothctl:
# [bluetooth]# show
# [bluetooth]# power on
# [bluetooth]# agent on
# [bluetooth]# default-agent

# Для высококачественного аудио через Bluetooth:
pactl load-module module-bluetooth-discover
```

### Игровая оптимизация

Система включает оптимизации для игр:

```bash
# Проверить поддержку Vulkan
vulkaninfo

# Запуск игр с MangoHUD
mangohud your-game

# Steam с Proton оптимизация уже настроена
```
