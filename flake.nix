{
  description = "Meowrch NixOS Configuration - A beautiful Hyprland rice for NixOS 25.05";

  inputs = {
    # Stable NixOS 25.05 channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    # Unstable channel for latest packages when needed
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hyprland from stable
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.45.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    
    # Hardware configuration
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    # Firefox addons
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, hyprland-plugins, nixos-hardware, firefox-addons, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Stable packages
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = pkg: true;
        };
      };
      
      # Unstable packages overlay
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      
      # Custom packages and scripts
      meowrch-scripts = pkgs.callPackage ./packages/meowrch-scripts.nix { };
      meowrch-themes = pkgs.callPackage ./packages/meowrch-themes.nix { };
      
    in {
      # NixOS configuration
      nixosConfigurations = {
        meowrch = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { 
            inherit inputs;
            inherit hyprland;
            inherit hyprland-plugins;
          };
          modules = [
            # Apply unstable overlay
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            
            # Hardware configuration
            ./hardware-configuration.nix
            
            # Main system configuration
            ./configuration.nix
            
            # Hyprland module
            hyprland.nixosModules.default
            
            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { 
                inherit inputs;
                inherit firefox-addons;
                inherit meowrch-scripts;
                inherit meowrch-themes;
              };
              home-manager.users.redm00us = import ./home/home.nix;
            }
            
            # System modules
            ./modules/system/audio.nix
            ./modules/system/bluetooth.nix
            ./modules/system/graphics.nix
            ./modules/system/networking.nix
            ./modules/system/security.nix
            ./modules/system/services.nix
            ./modules/system/fonts.nix
            
            # Desktop modules
            ./modules/desktop/hyprland.nix
            ./modules/desktop/sddm.nix
            ./modules/desktop/theming.nix
          ];
        };
      };
      
      # Development shell
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
          echo "  - home-manager switch --flake .#meowrch"
        '';
      };
      
      # Standalone home-manager configuration
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
            ./home/home.nix
          ];
        };
      };
      
      # Custom packages
      packages.${system} = {
        inherit meowrch-scripts meowrch-themes;
        default = meowrch-scripts;
      };
    };
}