# 🐱 Meowrch NixOS Configuration ≽ܫ≼

![Meowrch Logo](https://raw.githubusercontent.com/meowrch/meowrch/main/.meta/logo.png)

A beautiful, performance-optimized NixOS configuration based on the Meowrch Arch Linux rice, featuring Hyprland with custom themes, scripts, and a complete desktop environment.

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

## 🌟 Overview

This NixOS configuration recreates the entire Meowrch desktop experience on NixOS 25.05 stable, providing:
- **Hyprland** as the primary Wayland compositor
- **Waybar** with custom modules and beautiful styling
- **Kitty** terminal with Catppuccin theme
- **Fish** shell with custom functions and aliases
- **Rofi** application launcher with custom menus
- Complete **theme management** system
- **Custom scripts** for system management
- **Home Manager** integration for user configuration

## ✨ Features

### 🎨 Desktop Environment
- **Hyprland**: Latest stable Wayland compositor with blur effects and animations
- **Waybar**: Highly customized status bar with system monitoring
- **Rofi**: Beautiful application launcher with power menu, emoji picker, and more
- **Dunst**: Notification daemon with custom styling
- **SDDM**: Login manager with Wayland support

### 🛠️ Applications & Tools
- **Kitty**: GPU-accelerated terminal with JetBrainsMono Nerd Font
- **Fish**: Modern shell with custom functions and starship prompt
- **Firefox**: Web browser with privacy-focused settings
- **VSCode**: Development environment
- **Nemo**: File manager
- **Custom Scripts**: Volume, brightness, screenshot, color picker, and more

### 🎯 System Features
- **Stable NixOS 25.05**: Rock-solid base with unstable overlay for select packages
- **Flake-based**: Reproducible and declarative configuration
- **Home Manager**: User-level package and configuration management
- **Graphics Drivers**: Support for Intel, AMD, and NVIDIA
- **Gaming**: Steam, GameMode, MangoHUD support
- **Development**: Python, Node.js, Rust, Go, and more

### 🎭 Theming
- **Catppuccin**: Beautiful color scheme throughout the system
- **Custom Waybar**: Styled to match the original Meowrch aesthetic
- **GTK/Qt**: Consistent theming across all applications
- **Icons**: Papirus icon theme with dark variants
- **Cursors**: Bibata cursor theme
- **Wallpapers**: Curated collection of beautiful backgrounds

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

### 1. Clone the Repository

```bash
git clone https://github.com/meowrch/meowrch.git
cd meowrch/NixOS-25.05
```

### 2. Hardware Configuration

Copy your existing hardware configuration:

```bash
# Copy from your current NixOS installation
sudo cp /etc/nixos/hardware-configuration.nix .
```

Or generate a new one:

```bash
# Generate hardware configuration
sudo nixos-generate-config --root /mnt --show-hardware-config > hardware-configuration.nix
```

### 3. Customize Configuration

Edit the main configuration files to match your system:

```bash
# Edit user settings
nano configuration.nix

# Adjust home manager settings
nano home/home.nix
```

Key things to customize:
- Username in `configuration.nix` and `home/home.nix`
- Time zone in `configuration.nix`
- Monitor configuration in `home/modules/hyprland.nix`
- Network settings if needed

### 4. Build and Switch

```bash
# Build the configuration
sudo nixos-rebuild switch --flake .#meowrch

# Reboot to apply all changes
sudo reboot
```

### 5. Post-Installation Setup

After reboot, log in and run:

```bash
# Apply home manager configuration
home-manager switch --flake .#meowrch

# Set up themes and wallpapers
python ~/.config/meowrch/meowrch.py --action set-current-theme
python ~/.config/meowrch/meowrch.py --action set-wallpaper
```

## ⚙️ Configuration

### User Management

To change the username from `meowrch`:

1. Edit `configuration.nix`:
```nix
users.users.YOUR_USERNAME = {
  # ... user configuration
};
```

2. Edit `home/home.nix`:
```nix
home = {
  username = "YOUR_USERNAME";
  homeDirectory = "/home/YOUR_USERNAME";
  # ...
};
```

3. Update flake.nix references if needed.

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

| Action | Hyprland Shortcut |
|--------|------------------|
| Open Terminal | `Super + Enter` |
| Open App Launcher | `Super + D` |
| Open File Manager | `Super + E` |
| Take Screenshot | `Print Screen` |
| Lock Screen | `Super + L` |
| Change Wallpaper | `Super + W` |
| Change Theme | `Super + T` |
| Volume Up/Down | `XF86AudioRaiseVolume/LowerVolume` |
| Brightness Up/Down | `XF86MonBrightnessUp/Down` |
| Close Window | `Super + Q` |
| Toggle Floating | `Super + Space` |
| Fullscreen | `Alt + Enter` |
| Switch Workspace | `Super + 1-10` |
| Move Window to Workspace | `Super + Shift + 1-10` |

### Custom Scripts

The configuration includes many custom scripts accessible via:

```bash
# Volume control
~/bin/volume.sh --help

# Brightness control
~/bin/brightness.sh --help

# Color picker
~/bin/color-picker.sh

# System information
~/bin/system-info.py --help

# Theme management
python ~/.config/meowrch/meowrch.py --help
```

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

#### System Packages
Add to `configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  # Your packages here
  neovim
  discord
];
```

#### User Packages
Add to `home/home.nix`:
```nix
home.packages = with pkgs; [
  # Your packages here
  spotify
  gimp
];
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

### Common Issues

#### 1. Build Failures
```bash
# Clear build cache
sudo nix-collect-garbage -d

# Update flake inputs
nix flake update

# Rebuild
sudo nixos-rebuild switch --flake .#meowrch
```

#### 2. Graphics Issues
```bash
# Check graphics drivers
lspci | grep VGA
glxinfo | grep vendor

# For NVIDIA users, ensure drivers are loaded
lsmod | grep nvidia
```

#### 3. Audio Issues
```bash
# Check audio services
systemctl --user status pipewire

# Restart audio
systemctl --user restart pipewire pipewire-pulse
```

#### 4. Home Manager Issues
```bash
# Reset home manager
home-manager switch --flake .#meowrch

# Check for conflicts
home-manager news
```

### Logs and Debugging

```bash
# System logs
journalctl -xe

# Hyprland logs
cat ~/.cache/hyprland/hyprland.log

# Home manager logs
home-manager news
```

## 🔄 Updates

### Updating the System

```bash
# Update flake inputs
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#meowrch

# Update home manager
home-manager switch --flake .#meowrch
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

## 📚 Resources

- [Original Meowrch Project](https://github.com/meowrch/meowrch)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Catppuccin Theme](https://github.com/catppuccin)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- **Meowrch Team**: For the original beautiful rice
- **NixOS Community**: For the amazing package manager and OS
- **Hyprland Developers**: For the excellent Wayland compositor
- **Catppuccin Team**: For the beautiful color schemes
- **All Contributors**: Who help make this project better

---

**Made with ❤️ by the Meowrch community**

*If you enjoy this configuration, please consider starring the repository and sharing it with others!*