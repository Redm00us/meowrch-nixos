# 🐱 Meowrch NixOS Configuration ≽ܫ≼

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-25.05-5277C3.svg?style=for-the-badge&logo=nixos&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-00D9FF.svg?style=for-the-badge&logo=wayland&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

*A beautiful, optimized NixOS configuration inspired by the Meowrch Arch Linux rice*

[Features](#-features) • [Installation](#-quick-installation) • [Screenshots](#-screenshots) • [Customization](#-customization) • [Support](#-support)

</div>

---

## 🌟 Overview

This is a complete NixOS 25.05 configuration that recreates the beautiful Meowrch desktop experience with modern tools and optimizations. Built with reproducibility and performance in mind, it provides a stunning Wayland desktop environment powered by Hyprland.

### ✨ What makes this special?
- 🎨 **Beautiful theming** with Catppuccin color schemes
- ⚡ **Optimized performance** for both productivity and gaming
- 🔧 **Highly customizable** modular configuration
- 📦 **Reproducible builds** with Nix flakes
- 🛡️ **Secure by default** with hardened settings

---

## 🚀 Quick Installation

### Option 1: Automated Installation (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/Redm00us/meowrch-nixos/main/install.sh | bash
```

### Option 2: Manual Installation
```bash
# Clone the repository
git clone https://github.com/Redm00us/meowrch-nixos.git
cd meowrch-nixos

# Generate hardware configuration
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix .

# Install the system
sudo nixos-install --flake .#meowrch
```

---

## ✨ Features

### 🎨 Desktop Environment
- **🪟 Hyprland** - Modern Wayland compositor with stunning animations
- **📊 Waybar** - Highly customized status bar with system monitoring
- **🚀 Rofi** - Beautiful application launcher with custom menus
- **🔔 Dunst** - Stylish notification daemon
- **🖥️ SDDM** - Clean login manager with Wayland support

### 🛠️ Applications & Tools
- **🐱 Kitty** - GPU-accelerated terminal with JetBrains Mono
- **🐟 Fish Shell** - Modern shell with custom functions and starship prompt
- **🦊 Firefox** - Web browser with privacy optimizations
- **📁 Nemo** - Feature-rich file manager
- **🎮 Steam** - Gaming platform with full compatibility
- **📦 Flatpak** - Universal package management

### 🎯 System Features
- **🔄 NixOS 25.05** - Stable base with unstable overlay for select packages
- **❄️ Flake-based** - Reproducible and declarative configuration
- **🏠 Home Manager** - User-space configuration management
- **🔊 PipeWire** - Modern audio system with low latency
- **🔗 Bluetooth** - Full wireless device support
- **🎮 AMD Graphics** - Optimized GPU drivers and performance

### 🎨 Theming
- **🌈 Catppuccin** - Beautiful pastel color schemes (Mocha & Latte)
- **🎭 Dynamic themes** - Easy switching between light and dark modes
- **🖼️ Custom wallpapers** - Curated collection of beautiful backgrounds
- **🎪 GRUB theme** - Stylish bootloader with custom icons

---

## 📋 Requirements

### Hardware
- **CPU**: x86_64 architecture (Intel/AMD)
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: 20GB minimum, 50GB+ recommended for full experience
- **GPU**: AMD graphics card (optimized configuration)

### Knowledge Level
- **Beginner**: Use automated installer
- **Intermediate**: Manual installation with customization
- **Advanced**: Full configuration modification

---

## 🖼️ Screenshots

*Coming soon - beautiful desktop screenshots showcasing the Meowrch experience*

---

## 🎮 Usage

### 🔥 Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + D` | Application launcher (Rofi) |
| `Super + Q` | Close window |
| `Super + F` | Toggle fullscreen |
| `Super + Space` | Toggle floating |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + Print` | Screenshot |
| `Super + L` | Lock screen |

### 🐟 Fish Shell Aliases
```bash
# System management
ll          # ls -la with colors
la          # ls -A with colors
rebuild     # Rebuild NixOS configuration
update      # Update system packages
cleanup     # Clean old generations

# Git shortcuts
gst         # git status
gco         # git checkout
gp          # git push
gl          # git pull
```

---

## 🎨 Customization

### 🎭 Changing Themes
```bash
# Switch to light theme
theme-switch latte

# Switch to dark theme  
theme-switch mocha

# Apply changes
rebuild
```

### 📦 Adding Packages

#### System packages (configuration.nix)
```nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  neofetch
  htop
];
```

#### User packages (home.nix)
```nix
home.packages = with pkgs; [
  # Add user-specific packages
  discord
  spotify
];
```

#### Flatpak applications
```bash
flatpak install flathub com.spotify.Client
```

---

## 🔧 Troubleshooting

### Common Issues

#### 🚫 "Hardware configuration not found"
```bash
# Generate hardware config
sudo nixos-generate-config
cp /etc/nixos/hardware-configuration.nix .
```

#### 🔊 Audio not working
```bash
# Restart PipeWire
systemctl --user restart pipewire
```

#### 🖥️ Display issues
```bash
# Check Hyprland logs
journalctl --user -u hyprland
```

#### 📦 Package build failures
```bash
# Clear nix store
sudo nix-collect-garbage -d
# Rebuild
sudo nixos-rebuild switch --flake .#meowrch
```

---

## 🔄 Updates

### Update System
```bash
# Update flake inputs
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#meowrch
```

### Update Individual Packages
```bash
# Update specific input
nix flake lock --update-input nixpkgs
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **🐛 Report bugs** - Open an issue with detailed information
2. **💡 Suggest features** - Share your ideas for improvements
3. **🔧 Submit fixes** - Fork, fix, and create a pull request
4. **📚 Improve docs** - Help make the documentation better
5. **🎨 Create themes** - Design new color schemes or layouts

### Development Setup
```bash
git clone https://github.com/Redm00us/meowrch-nixos.git
cd meowrch-nixos
nix develop  # Enter development shell
```

---

## 📚 Resources

- **🏠 [NixOS Manual](https://nixos.org/manual/nixos/stable/)** - Official documentation
- **❄️ [Nix Pills](https://nixos.org/guides/nix-pills/)** - Learn Nix language
- **🏡 [Home Manager](https://nix-community.github.io/home-manager/)** - User configuration
- **🪟 [Hyprland Wiki](https://wiki.hyprland.org/)** - Wayland compositor guide
- **🎨 [Catppuccin](https://catppuccin.com/)** - Theme collection

---

## 💬 Support

### 🆘 Need Help?
- **📧 Issues**: [GitHub Issues](https://github.com/Redm00us/meowrch-nixos/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/Redm00us/meowrch-nixos/discussions)
- **🐱 Matrix**: `#meowrch:matrix.org`

### 🐛 Reporting Bugs
When reporting issues, please include:
- Your hardware configuration
- NixOS version (`nixos-version`)
- Error messages or logs
- Steps to reproduce

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **🎨 [Catppuccin](https://catppuccin.com/)** - Beautiful color schemes
- **🪟 [Hyprland](https://hyprland.org/)** - Amazing Wayland compositor  
- **❄️ [NixOS](https://nixos.org/)** - Reproducible system configuration
- **🐱 [Meowrch](https://github.com/meowrch)** - Original Arch Linux rice inspiration

---

<div align="center">

**⭐ If you found this helpful, please consider giving it a star! ⭐**

*Made with 💜 and lots of ☕*

</div>