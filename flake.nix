# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                     Конфигурационный файл Flake                          ║
# ║                         Сделал: Redm00us                                 ║
# ║                                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

{
  description = "Конфигурация NixOS redm00us (NixOS 25.05 + ядро/пакеты unstable)";

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                              INPUTS                                  ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  inputs = {
    # ────────────── Основные каналы Nixpkgs ──────────────
    nixpkgs = {                                   # Стабильная ветка Nixpkgs (основная)
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    nixpkgs-unstable = {                          # Нестабильная ветка Nixpkgs (для свежих пакетов)
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # ────────────── Менеджер домашней директории ──────────────
    home-manager = {                              # Home Manager (управление пользовательской конфигурацией)
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ────────────── Hyprland ──────────────
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.45.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # ────────────── Темы и оформление ──────────────
    catppuccin-nix = {                            # Catppuccin Theme (глобальная тема)
      url = "github:catppuccin/nix";
    };

    # ────────────── Мультимедиа ──────────────
    yandex-music = {                              # Yandex Music (неофициальный клиент)
      url = "github:cucumber-sp/yandex-music-linux";
    };
    spicetify-nix = {                             # Spicetify (кастомизация Spotify)
      url = "github:Gerg-L/spicetify-nix";
    };

    # ────────────── Браузеры ──────────────
    zen-browser = {                               # Zen Browser (альтернативный браузер)
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ────────────── Аппаратное обеспечение ──────────────
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # ────────────── Firefox addons ──────────────
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════╗
  # ║                              OUTPUTS                                 ║
  # ╚════════════════════════════════════════════════════════════════════════╝
  outputs = { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , hyprland
    , hyprland-plugins
    , yandex-music
    , spicetify-nix
    , catppuccin-nix
    , nixos-hardware
    , firefox-addons
    , zen-browser
    , ...
  }@inputs:
  let
    # ────────────── Системные параметры ──────────────
    system = "x86_64-linux";                      # Архитектура системы

    # ────────────── Импорт пакетов ──────────────
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;                  # Разрешить проприетарные пакеты
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # ────────────── Overlay для unstable пакетов ──────────────
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    # ────────────── Кастомные пакеты ──────────────
    meowrch-scripts = pkgs.callPackage ./packages/meowrch-scripts.nix { };
    meowrch-themes = pkgs.callPackage ./packages/meowrch-themes.nix { };
  in
  {
    # ────────────── Конфигурация NixOS ──────────────
    nixosConfigurations."meowrch" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        # Передача переменных и пакетов в модули
        inherit inputs pkgs-unstable yandex-music spicetify-nix catppuccin-nix zen-browser;
        inherit hyprland hyprland-plugins;
      };
      modules = [
        # Apply unstable overlay
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })

        # Основная системная конфигурация
        ./configuration.nix

        # Hyprland модуль
        hyprland.nixosModules.default

        # Catppuccin модуль
        catppuccin-nix.nixosModules.catppuccin

        # Модуль Home Manager
        home-manager.nixosModules.home-manager
        {
          # ────────────── Настройки Home Manager ──────────────
          home-manager.useGlobalPkgs = true;                # Использовать глобальные пакеты
          home-manager.useUserPackages = true;              # Использовать пользовательские пакеты
          nixpkgs.config.allowUnfree = true;                # Разрешить проприетарные пакеты

          home-manager.extraSpecialArgs = {
            inherit inputs;
            inherit firefox-addons;
            inherit meowrch-scripts;
            inherit meowrch-themes;
          }; # Передача inputs в Home Manager

          home-manager.users.redm00us = {
            imports = [
              inputs.spicetify-nix.homeManagerModules.default  # Модуль Spicetify для Home Manager
              inputs.catppuccin-nix.homeModules.catppuccin     # Catppuccin для Home Manager (обновленный путь)
              ./home/home.nix                                      # Пользовательская конфигурация
            ];
          };
          home-manager.backupFileExtension = "backup";         # Расширение для бэкапов Home Manager
        }

        # Desktop modules
        ./modules/desktop/hyprland.nix
      ];
    };

    # ────────────── Development shell ──────────────
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nixos-rebuild
        home-manager
        git
        vim
      ];

      shellHook = ''
        echo "🐱 Welcome to Meowrch NixOS Development Environment!"
        echo "Available commands:"
        echo "  - nixos-rebuild switch --flake .#meowrch"
        echo "  - home-manager switch --flake .#redm00us"
      '';
    };

    # ────────────── Standalone home-manager configuration ──────────────
    homeConfigurations = {
      redm00us = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          inherit firefox-addons;
          inherit meowrch-scripts;
          inherit meowrch-themes;
        };
        modules = [
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          inputs.catppuccin-nix.homeModules.catppuccin
          ./home/home.nix
        ];
      };
    };

    # ────────────── Custom packages ──────────────
    packages.${system} = {
      inherit meowrch-scripts meowrch-themes;
      default = meowrch-scripts;
    };
  };
}
