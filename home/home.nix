{ config, pkgs, inputs, firefox-addons, meowrch-scripts, meowrch-themes, ... }:

{
  # Home Manager Configuration
  home = {
    username = "redm00us";
    homeDirectory = "/home/redm00us";
    stateVersion = "25.05";

    # Home packages
    packages = with pkgs; [
      # Terminal and Shell
      kitty
      fish
      starship
      fastfetch
      lsd
      bat
      tree
      btop
      micro
      neovim
      tmux

      # Desktop Environment
      waybar
      rofi-wayland
      dunst
      swww
      wl-clipboard
      cliphist
      xdg-desktop-portal-hyprland
      qt5.qtwayland
      qt6.qtwayland
      hypridle
      hyprpicker
      swaylock-effects
      grimblast

      # Applications
      firefox
      nemo
      pavucontrol
      blueman
      networkmanagerapplet
      
      # Development
      vscode
      git
      python3
      nodejs
      
      # Multimedia
      vlc
      loupe
      flameshot
      cava
      
      # Utilities
      ranger
      udiskie
      brightnessctl
      pamixer
      playerctl
      polkit_gnome
      gnome-calculator
      timeshift
      
      # Fonts
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" "Iosevka" ]; })
      
      # Gaming
      steam
      gamemode
      mangohud
      
      # Social
      telegram-desktop
      discord
      
      # Themes and Icons
      papirus-icon-theme
      bibata-cursors
      
      # Scripts
      meowrch-scripts
      meowrch-themes
      
      # System Tools
      jq
      parallel
      wget
      curl
      unzip
      unrar
      p7zip
      zenity
      cowsay
      pokemon-colorscripts-mac
    ];

    # Session Variables
    sessionVariables = {
      EDITOR = "micro";
      VISUAL = "micro";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      MICRO_TRUECOLOR = "1";
      
      # XDG Directories
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
      
      # Application specific
      GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
      XCURSOR_PATH = "/usr/share/icons:$XDG_DATA_HOME/icons";
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      GNUPGHOME = "$XDG_DATA_HOME/gnupg";
      REDISCLI_HISTFILE = "$XDG_DATA_HOME/redis/rediscli_history";
      RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
      NODE_REPL_HISTORY = "$XDG_DATA_HOME/node_repl_history";
      PYENV_ROOT = "$XDG_DATA_HOME/pyenv";
      WAKATIME_HOME = "$XDG_CONFIG_HOME/wakatime";
      
      # Wayland/Qt
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_SCALE = "1";
      
      # Java
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dsun.java2d.opengl=true";
    };
  };

  # Import home modules
  imports = [
    ./modules/hyprland.nix
    ./modules/waybar.nix
    ./modules/kitty.nix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/rofi.nix
    ./modules/dunst.nix
    ./modules/gtk.nix
  ];

  # XDG User Directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };
    
    # MIME type associations
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "micro.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        "image/jpeg" = [ "loupe.desktop" ];
        "image/png" = [ "loupe.desktop" ];
        "image/gif" = [ "loupe.desktop" ];
        "video/mp4" = [ "vlc.desktop" ];
        "video/x-matroska" = [ "vlc.desktop" ];
        "audio/mpeg" = [ "vlc.desktop" ];
        "audio/flac" = [ "vlc.desktop" ];
        "inode/directory" = [ "nemo.desktop" ];
      };
    };
  };

  # Enable fontconfig
  fonts.fontconfig.enable = true;

  # Programs configuration
  programs = {
    # Home Manager
    home-manager.enable = true;
    
    # Direnv for development environments
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
    # Zoxide for smart cd
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
    
    # Fzf for fuzzy finding
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    
    # Eza (modern ls)
    eza = {
      enable = true;
      enableFishIntegration = true;
      icons = true;
      git = true;
    };
    
    # Gpg
    gpg.enable = true;
  };

  # Services
  services = {
    # GPG Agent
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
    
    # Syncthing
    syncthing.enable = true;
  };

  # File configurations
  home.file = {
    # Meowrch theme management script
    ".config/meowrch/meowrch.py".source = ../dotfiles/meowrch/meowrch.py;
    
    # Custom scripts directory
    "bin" = {
      source = ../dotfiles/bin;
      recursive = true;
      executable = true;
    };
    
    # Wallpapers (commented out - create dotfiles/wallpapers if needed)
    # ".local/share/wallpapers" = {
    #   source = ../dotfiles/wallpapers;
    #   recursive = true;
    # };
    
    # Icons (commented out - create dotfiles/icons if needed)
    # ".local/share/icons" = {
    #   source = ../dotfiles/icons;
    #   recursive = true;
    # };
    
    # Themes (commented out - create dotfiles/themes if needed)
    # ".local/share/themes" = {
    #   source = ../dotfiles/themes;
    #   recursive = true;
    # };
    
    # User dirs configuration
    ".config/user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOWNLOAD_DIR="$HOME/Downloads"
      XDG_TEMPLATES_DIR="$HOME/Templates"
      XDG_PUBLICSHARE_DIR="$HOME/Public"
      XDG_DOCUMENTS_DIR="$HOME/Documents"
      XDG_MUSIC_DIR="$HOME/Music"
      XDG_PICTURES_DIR="$HOME/Pictures"
      XDG_VIDEOS_DIR="$HOME/Videos"
    '';
    
    # Qt5 settings
    ".config/qt5ct/qt5ct.conf".text = ''
      [Appearance]
      color_scheme_path=/usr/share/qt5ct/colors/airy.conf
      custom_palette=false
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=gtk2
      
      [Fonts]
      fixed=@Variant(\0\0\0@\0\0\0\x1c\0J\0\x65\0t\0\x42\0r\0\x61\0i\0n\0s\0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
      general=@Variant(\0\0\0@\0\0\0\x16\0N\0o\0t\0o\0 \0S\0\x61\0n\0s@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
      
      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3
    '';
    
    # Qt6 settings
    ".config/qt6ct/qt6ct.conf".text = ''
      [Appearance]
      color_scheme_path=/usr/share/qt6ct/colors/airy.conf
      custom_palette=false
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=gtk2
      
      [Fonts]
      fixed=@Variant(\0\0\0@\0\0\0\x1c\0J\0\x65\0t\0\x42\0r\0\x61\0i\0n\0s\0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
      general=@Variant(\0\0\0@\0\0\0\x16\0N\0o\0t\0o\0 \0S\0\x61\0n\0s@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
      
      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3
    '';
  };
}