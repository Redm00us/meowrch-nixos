{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/graphics.nix
    ./modules/system/networking.nix
    ./modules/system/security.nix
    ./modules/system/services.nix
    ./modules/system/fonts.nix
    ./modules/desktop/sddm.nix
    ./modules/desktop/theming.nix
  ];

  # System Information
  system.stateVersion = "25.05";
  
  # Nix Configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Nixpkgs Configuration
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: true;
  };

  # Boot Configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    
    # Basic kernel parameters (AMD and other specific params defined in modules)
    kernelParams = [
      "quiet"
      "splash"
      "mitigations=off"
    ];
    
    # Enable latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Plymouth for boot splash
    plymouth = {
      enable = true;
      theme = "spinner";
    };
  };

  # Hardware Configuration (specific hardware configs are in their respective modules)
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  # Users Configuration
  users = {
    defaultUserShell = pkgs.fish;
    users.redm00us = {
      isNormalUser = true;
      description = "Meowrch User";
      extraGroups = [ 
        "wheel" 
        "networkmanager" 
        "audio" 
        "video" 
        "storage" 
        "optical" 
        "scanner" 
        "power"
        "input"
        "uucp"
        "bluetooth"
        "render"
        "secure"
      ];
      shell = pkgs.fish;
    };
  };

  # Environment Configuration
  environment = {
    systemPackages = with pkgs; [
      # Core System Tools
      wget curl git vim nano
      htop btop fastfetch
      unzip unrar p7zip
      tree file which
      
      # Development Tools
      gcc clang cmake make
      python3 python3Packages.pip
      nodejs npm
      
      # System Utilities
      usbutils pciutils
      lshw dmidecode
      parted gparted
      
      # Archive Tools
      ark
      
      # Network Tools
      networkmanager
      openssh
      
      # Media Tools
      ffmpeg
      imagemagick
      
      # File Management
      ranger
      nemo
      
      # System Monitoring
      htop
      btop
      radeontop
      
      # Bluetooth
      bluez
      blueman
      
      # Graphics utilities
      glxinfo
      vulkan-tools
      mesa-demos
      
      # Authentication
      polkit_gnome
    ];

    # Session Variables
    sessionVariables = {
      # XDG Directories
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
      
      # Application Settings
      EDITOR = "micro";
      VISUAL = "micro";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      
      # Wayland/X11 Settings
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_SCALE = "1";
      
      # AMD Graphics
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
      AMD_VULKAN_ICD = "RADV";
      
      # Java Settings
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dsun.java2d.opengl=true";
    };

    # Shell Aliases
    shellAliases = {
      cls = "clear";
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
      g = "git";
      n = "nvim";
      m = "micro";
      
      # NixOS specific
      rebuild = "sudo nixos-rebuild switch --flake .#meowrch";
      update = "nix flake update";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";
    };
  };

  # Programs Configuration
  programs = {
    # Fish Shell
    fish.enable = true;
    
    # Dconf for GTK settings
    dconf.enable = true;
    
    # Hyprland (defined in home-manager configuration for user)
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
    };
    
    # Steam
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    
    # Git
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
      };
    };
    
    # Thunar file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  # Services Configuration
  services = {
    # Desktop Portal
    xserver = {
      enable = false;
      desktopManager.plasma5.enable = false;
      displayManager = {
        defaultSession = "hyprland";
      };
    };
    
    # Printing
    printing.enable = true;
    
    # Time Synchronization
    timesyncd.enable = true;
    
    # Power Management
    power-profiles-daemon.enable = true;
    
    # Firmware Updates
    fwupd.enable = true;
    
    # Flatpak
    flatpak.enable = true;
    
    # GVFS for file manager
    gvfs.enable = true;
    
    # Tumbler for thumbnails
    tumbler.enable = true;
  };

  # Security Configuration
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    
    # Sudo configuration
    sudo = {
      enable = true;
      extraRules = [{
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl suspend";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }];
    };
  };

  # XDG Configuration
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };
  };

  # Time Zone and Localization
  time.timeZone = "Europe/Moscow";
  
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Console Configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Virtualization
  virtualisation = {
    docker.enable = true;
    waydroid.enable = true;
  };

  # Systemd Services
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}