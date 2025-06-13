# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Home-Manager                   ║
# ║                         Оптимизирован для NixOS 25.05                    ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

{ config, pkgs, lib, inputs, firefox-addons, meowrch-scripts, meowrch-themes, ... }:

{
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                         Основные настройки Home Manager                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.username = "redm00us";
  home.homeDirectory = "/home/redm00us";
  home.stateVersion = "25.05";

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Overlays                                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  nixpkgs.overlays = [
    # Overlay для Spicetify
    inputs.spicetify-nix.overlays.default
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                           Пользовательские пакеты                        ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.packages = with pkgs; [
    # --- Музыкальный плеер Яндекс.Музыка ---
    inputs.yandex-music.packages.${pkgs.system}.default

    # --- Zen Browser ---
    inputs.zen-browser.packages.${pkgs.system}.default

    # --- Кастомные скрипты и темы ---
    meowrch-scripts
    meowrch-themes

    # --- Дополнительные пакеты пользователя ---
    # Добавьте здесь свои пакеты
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                               Fish Shell                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.fish = {
    enable = true;

    # --- Алиасы ---
    shellAliases = {
      # Быстрая пересборка системы
      b = "sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure";
      # Открыть конфиг NixOS в редакторе
      c = "cd /home/redm00us/NixOS-25.05 && zed .";
      # Обновить флейк и пересобрать систему
      u = "cd /home/redm00us/NixOS-25.05 && nix flake update && sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#meowrch --impure";
      # Быстрый вывод информации о системе
      f = "fastfetch";
      # Очистка мусора Nix
      dell = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      # Home Manager
      hm = "home-manager switch --flake .#redm00us";
      # Быстрые команды
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
      cls = "clear";
      # Git сокращения
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
    };

    # --- Пользовательские функции ---
    functions = {
      # wget с поддержкой XDG_DATA_HOME
      wget = ''
        command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
      '';

      # Функция для быстрого поиска файлов
      ff = ''
        find . -type f -name "*$argv*" 2>/dev/null
      '';

      # Функция для создания и перехода в директорию
      mkcd = ''
        mkdir -p $argv[1] && cd $argv[1]
      '';
    };

    # --- Инициализация интерактивной оболочки ---
    interactiveShellInit = ''
      set fish_greeting ""

      # Добавить ~/.local/bin в PATH, если его нет
      if not contains -- "$HOME/.local/bin" $fish_user_paths
          set -p fish_user_paths "$HOME/.local/bin"
      end

      # Добавить директорию скриптов в PATH
      if not contains -- "$HOME/.config/meowrch/bin" $fish_user_paths
          set -p fish_user_paths "$HOME/.config/meowrch/bin"
      end

      # Красивый вывод информации о системе при запуске
      fastfetch
    '';
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Starship Prompt                             ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format = "$all$character";

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      git_branch = {
        style = "bold purple";
      };

      nix_shell = {
        format = "via [$symbol$state]($style) ";
        symbol = "❄️ ";
        style = "bold blue";
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                        Переменные окружения                              ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  home.sessionVariables = {
    # Wayland support
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";

    # XDG directories
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";

    # Default applications
    EDITOR = "zed";
    VISUAL = "zed";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    # Development
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                   Git                                    ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.git = {
    enable = true;
    userName = "Redm00us";
    userEmail = "krokismau@icloud.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.default = "simple";
      core.autocrlf = "input";

      # Git aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        lg = "log --oneline --graph --decorate --all";
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                Spicetify                                 ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.spicetify = {
    enable = true;
    # Тема Catppuccin для Spicetify
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.system}.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.system}.extensions; [
      adblock
      hidePodcasts
      shuffle
    ];
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Catppuccin Theme                            ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Firefox                                     ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      extensions = with firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        bitwarden
        privacy-badger
        decentraleyes
        clearurls
      ];

      settings = {
        # Privacy and security
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;

        # Wayland
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                  Kitty                                   ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  programs.kitty = {
    enable = true;

    settings = {
      # Font configuration
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;

      # Window layout
      remember_window_size = false;
      initial_window_width = 1200;
      initial_window_height = 800;

      # Colors will be set by Catppuccin

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;

      # Wayland settings
      wayland_titlebar_color = "system";
      linux_display_server = "wayland";

      # Scrollback
      scrollback_lines = 10000;

      # URLs
      url_style = "curly";
      open_url_with = "default";

      # Bell
      enable_audio_bell = false;
      visual_bell_duration = 0.0;

      # Window settings
      confirm_os_window_close = 0;
      background_opacity = 0.95;
    };

    keybindings = {
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_window";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+r" = "start_resizing_window";
      "ctrl+shift+l" = "next_layout";
      "ctrl+shift+equal" = "increase_font_size";
      "ctrl+shift+minus" = "decrease_font_size";
      "ctrl+shift+backspace" = "restore_font_size";
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Zed Editor                                  ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Zed config file
  home.file.".config/zed/settings.json".text = builtins.toJSON {
    # Theme
    theme = "Catppuccin Mocha";

    # UI Settings
    ui_font_size = 14;
    buffer_font_size = 14;
    buffer_font_family = "JetBrainsMono Nerd Font";
    ui_font_family = "JetBrainsMono Nerd Font";

    # Editor settings
    tab_size = 2;
    soft_wrap = "editor_width";
    show_whitespaces = "all";
    relative_line_numbers = true;
    cursor_blink = true;

    # Git integration
    git.git_gutter = "tracked_files";
    git.inline_blame.enabled = true;

    # Language settings
    languages = {
      Nix = {
        language_servers = ["nil"];
        formatter = "alejandra";
      };
    };

    # Terminal
    terminal = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 14;
    };

    # Auto save
    autosave = "on_focus_change";
    format_on_save = "on";

    # File tree
    project_panel = {
      dock = "left";
      default_width = 240;
    };

    # Vim mode (optional)
    vim_mode = false;

    # Assistant (disable if not needed)
    assistant = {
      enabled = false;
    };
  };

  # Zed keymap file
  home.file.".config/zed/keymap.json".text = builtins.toJSON [
    {
      context = "Editor";
      bindings = {
        "ctrl-/" = "editor::ToggleComments";
        "ctrl-d" = "editor::SelectNext";
        "ctrl-shift-k" = "editor::DeleteLine";
        "ctrl-shift-d" = "editor::DuplicateLine";
        "ctrl-p" = "file_finder::Toggle";
        "ctrl-shift-p" = "command_palette::Toggle";
        "ctrl-shift-f" = "search::ToggleReplace";
        "ctrl-`" = "terminal_panel::ToggleFocus";
      };
    }
  ];

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                              Dotfiles                                    ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Создание необходимых директорий
  home.file.".local/bin/.keep".text = "";
  home.file.".config/meowrch/.keep".text = "";

  # Автоматический запуск Home Manager
  programs.home-manager.enable = true;

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                            Systemd Services                              ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  systemd.user.services = {
    # Автоматическое обновление wallpaper (если есть скрипты)
    wallpaper-changer = {
      Unit = {
        Description = "Random wallpaper changer";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'if [ -x $HOME/.config/meowrch/bin/change-wallpaper.sh ]; then $HOME/.config/meowrch/bin/change-wallpaper.sh; fi'";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                                 XDG                                      ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

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

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "image/jpeg" = [ "feh.desktop" ];
        "image/png" = [ "feh.desktop" ];
        "image/gif" = [ "feh.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "audio/mpeg" = [ "mpv.desktop" ];
        "audio/flac" = [ "mpv.desktop" ];
      };
    };
  };
}
