{ config, pkgs, lib, inputs, ... }:

{
  # Hyprland Configuration
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # XDG Desktop Portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  # Environment variables for Hyprland
  environment.sessionVariables = {
    # Wayland specific
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    
    # XDG specific
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    
    # For Java applications
    _JAVA_AWT_WM_NONREPARENTING = "1";
    
    # For correct cursor size
    XCURSOR_SIZE = "24";
  };

  # Dependencies for Hyprland
  environment.systemPackages = with pkgs; [
    # Core dependencies
    hyprland
    xdg-desktop-portal-hyprland
    waybar
    
    # Screen management tools
    wlr-randr
    
    # Screenshot and screen recording
    grim
    slurp
    wl-clipboard
    
    # Background and screenshots
    swww
    swayidle
    swaylock-effects
    
    # Notifications
    dunst
    libnotify
    
    # Input methods
    wl-clipboard
    cliphist
    
    # Utilities
    jq
    socat
    
    # Hyprland utilities
    hyprpicker
    hypridle
    
    # For animations and effects
    wlroots
  ];

  # Necessary services
  services = {
    # Gnome Keyring
    gnome.gnome-keyring.enable = true;
    
    # Enable dbus
    dbus = {
      enable = true;
      packages = with pkgs; [
        dbus.daemon
        dconf
      ];
    };
  };

  # Security-related settings for Hyprland
  security = {
    # For screen locking
    pam.services.swaylock = {};
    
    # Polkit for privilege escalation
    polkit.enable = true;
  };

  # Systemd services for Hyprland
  systemd = {
    user.services = {
      # Auto-start Hyprland session components
      xdg-desktop-portal-hyprland = {
        description = "Portal service for Hyprland";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
        serviceConfig = {
          Type = "dbus";
          BusName = "org.freedesktop.impl.portal.desktop.hyprland";
          ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
          Restart = "on-failure";
        };
      };
    };
  };

  # Desktop entries
  environment.systemPackages = with pkgs; [
    (writeTextFile {
      name = "hyprland-wrapped";
      destination = "/bin/hyprland-wrapped";
      executable = true;
      text = ''
        #!/bin/sh
        cd ~
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=Hyprland
        export XDG_CURRENT_DESKTOP=Hyprland
        exec ${inputs.hyprland.packages.${system}.hyprland}/bin/Hyprland $@
      '';
    })
  ];

  # Create XDG desktop entry for Hyprland
  environment.etc."xdg/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=Hyprland Tiling Wayland Compositor
    Exec=hyprland-wrapped
    Type=Application
    DesktopNames=Hyprland
  '';
  
  # Add to system path
  environment.pathsToLink = [ "/libexec" ];
}