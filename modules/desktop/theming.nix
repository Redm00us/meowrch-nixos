{ config, pkgs, lib, ... }:

{
  # Global System Theming Configuration
  
  # GRUB Theme configuration
  boot.loader = {
    grub = {
      enable = lib.mkDefault true;
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
      theme = pkgs.stdenv.mkDerivation {
        pname = "meowrch-grub-theme";
        version = "1.0.0";
        
        src = ../../../dotfiles/grub_theme;
        
        # If src doesn't exist, create a basic theme
        buildPhase = ''
          if [ ! -d "$src" ]; then
            mkdir -p $out/grub/themes/meowrch
            
            # Create a basic theme.txt
            cat > $out/grub/themes/meowrch/theme.txt << EOF
            # GRUB2 gfxmenu theme for Meowrch
            
            # Global settings
            title-text: ""
            desktop-image: "background.png"
            desktop-color: "#1e1e2e"
            terminal-font: "JetBrainsMono Regular 16"
            terminal-left: "0"
            terminal-top: "0"
            terminal-width: "100%"
            terminal-height: "100%"
            terminal-border: "0"
            
            # Boot menu
            + boot_menu {
                left = 15%
                top = 30%
                width = 70%
                height = 40%
                item_font = "JetBrainsMono Regular 16"
                item_color = "#cdd6f4"
                selected_item_color = "#89b4fa"
                item_height = 36
                item_spacing = 10
                selected_item_pixmap_style = "select_*.png"
            }
            
            # Progress bar
            + progress_bar {
                id = "__timeout__"
                left = 15%
                top = 80%
                width = 70%
                height = 18
                bg_color = "#313244"
                fg_color = "#89b4fa"
                border_color = "#45475a"
                text_color = "#cdd6f4"
                text = "Booting in %d seconds"
            }
            EOF
            
            # Create a basic background
            convert -size 1920x1080 xc:#1e1e2e $out/grub/themes/meowrch/background.png
            
            # Create selection images
            mkdir -p $out/grub/themes/meowrch/select
            for i in {1..3}; do
              convert -size 10x36 xc:#89b4fa $out/grub/themes/meowrch/select_$i.png
            done
          else
            mkdir -p $out/grub/themes/meowrch
            cp -r $src/* $out/grub/themes/meowrch/
          fi
        '';
        
        installPhase = ''
          mkdir -p $out
          cp -r grub $out/
        '';
        
        buildInputs = with pkgs; [ imagemagick ];
      };
    };
  };

  # Plymouth boot splash
  boot.plymouth = {
    enable = true;
    theme = "spinner";
    themePackages = [
      (pkgs.plymouth-theme-spinner.overrideAttrs (old: {
        postInstall = ''
          ${old.postInstall or ""}
          
          # Override spinner color to match Meowrch theme
          sed -i 's/Window.SetBackgroundTopColor(0.0, 0.0, 0.0);/Window.SetBackgroundTopColor(0.12, 0.12, 0.18);/g' $out/share/plymouth/themes/spinner/spinner.script
          sed -i 's/Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);/Window.SetBackgroundBottomColor(0.12, 0.12, 0.18);/g' $out/share/plymouth/themes/spinner/spinner.script
          sed -i 's/spinner_sprite.SetOpacity(0.1);/spinner_sprite.SetOpacity(0.8);/g' $out/share/plymouth/themes/spinner/spinner.script
        '';
      }))
    ];
  };

  # GTK/GNOME System-wide themes
  environment.systemPackages = with pkgs; [
    # GTK Themes
    adwaita-qt
    qgnomeplatform-qt6
    
    # Icon themes
    papirus-icon-theme
    
    # Cursor themes
    bibata-cursors
  ];

  # Default themes for system-wide apps
  environment.etc = {
    # GTK2 system-wide
    "gtk-2.0/gtkrc".text = ''
      gtk-theme-name = "Adwaita-dark"
      gtk-icon-theme-name = "Papirus-Dark"
      gtk-cursor-theme-name = "Bibata-Modern-Classic"
      gtk-cursor-theme-size = 24
      gtk-font-name = "Noto Sans 11"
    '';
    
    # GTK3 system-wide
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Adwaita-dark
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=24
      gtk-font-name=Noto Sans 11
      gtk-application-prefer-dark-theme=1
    '';
    
    # Icons theme
    "icons/default/index.theme".text = ''
      [Icon Theme]
      Inherits=Bibata-Modern-Classic
    '';
  };

  # System fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" "Iosevka" ]; })
    jetbrains-mono
    fira-code
    ubuntu-font-family
  ];

  # Meowrch theming for system programs
  environment.variables = {
    # Base theme variables
    GTK_THEME = "Adwaita:dark";
    
    # Icon and cursor theme
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };
  
  # XDG settings
  xdg.portal.config.common.default = "*";
}