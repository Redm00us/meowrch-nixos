{ config, pkgs, lib, ... }:

{
  # System Services Configuration
  services = {
    # Display Manager
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "breeze";
      settings = {
        General = {
          HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
          RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
        };
        Theme = {
          Current = "breeze";
          CursorTheme = "Bibata-Modern-Classic";
          CursorSize = 24;
        };
      };
    };

    # Desktop Portal
    xserver = {
      enable = false; # We use Wayland
      excludePackages = with pkgs; [ xterm ];
    };

    # Printing
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        epson-escpr
        canon-cups-ufr2
      ];
    };

    # Scanner support
    sane = {
      enable = true;
      extraBackends = with pkgs; [
        hplip
        epkowa
        sane-airscan
      ];
    };

    # Time synchronization
    timesyncd.enable = true;

    # Power management
    power-profiles-daemon.enable = true;
    
    # TLP for advanced power management (alternative to power-profiles-daemon)
    tlp = {
      enable = false; # Disabled in favor of power-profiles-daemon
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        ENERGY_PERF_POLICY_ON_AC = "performance";
        ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
      };
    };

    # UPower for battery information
    upower.enable = true;

    # Firmware updates
    fwupd.enable = true;

    # Flatpak support
    flatpak.enable = true;

    # GVFS for file manager functionality
    gvfs.enable = true;

    # Tumbler for thumbnails
    tumbler.enable = true;

    # Location services
    geoclue2.enable = true;

    # Thermald for thermal management (Intel)
    thermald.enable = lib.mkIf (config.hardware.cpu.intel.updateMicrocode or false) true;

    # Auto CPU frequency scaling
    auto-cpufreq = {
      enable = false; # Can conflict with power-profiles-daemon
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    # D-Bus
    dbus = {
      enable = true;
      packages = with pkgs; [
        gcr
        gnome.gnome-settings-daemon
      ];
    };

    # udev rules and services
    udev = {
      enable = true;
      packages = with pkgs; [
        gnome.gnome-settings-daemon
        android-udev-rules
      ];
      
      extraRules = ''
        # USB device rules
        SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", MODE="0664", GROUP="users"
        
        # Android devices
        SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="users"
        
        # Gaming controllers
        KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="*", MODE="0666"
        KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="*", MODE="0666"
        
        # Brightness control
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
        
        # Input devices
        SUBSYSTEM=="input", GROUP="input", MODE="0664"
        
        # Storage devices
        SUBSYSTEM=="block", TAG+="systemd"
      '';
    };

    # Logind configuration
    logind = {
      enable = true;
      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
      lidSwitch = "suspend";
      lidSwitchExternalPower = "suspend";
      lidSwitchDocked = "ignore";
      extraConfig = ''
        HandleSuspendKey=suspend
        HandleHibernateKey=hibernate
        IdleAction=ignore
        IdleActionSec=30min
        RuntimeDirectorySize=25%
        RemoveIPC=yes
        UserTasksMax=33%
      '';
    };

    # Locate database
    locate = {
      enable = true;
      package = pkgs.mlocate;
      localuser = null;
      interval = "02:15";
    };

    # System cleanup
    journald = {
      extraConfig = ''
        SystemMaxUse=500M
        SystemMaxFileSize=50M
        MaxRetentionSec=1week
        Compress=yes
        ForwardToSyslog=no
      '';
    };

    # Automatic garbage collection
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      optimise = {
        automatic = true;
        dates = [ "03:45" ];
      };
    };

    # Hardware monitoring
    smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        x11.enable = true;
        wall.enable = false;
        mail.enable = false;
      };
    };

    # Zram for compressed swap
    zram-generator = {
      enable = true;
      settings = {
        zram0 = {
          compression-algorithm = "zstd";
          zram-size = "ram / 2";
        };
      };
    };

    # Earlyoom for OOM prevention
    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 5;
      extraArgs = [
        "-g"
        "--avoid '^(systemd|kernel)$'"
        "--prefer '^(Web Content|firefox|chrome)$'"
      ];
    };

    # TRIM support for SSDs
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Automatic system updates (disabled by default)
    system-update = {
      enable = false;
      allowReboot = false;
    };

    # CUPS for printing
    printing = {
      enable = true;
      browsing = true;
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      defaultShared = false;
      openFirewall = true;
    };

    # Avahi for network discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    # UDisks2 for removable media
    udisks2.enable = true;

    # Polkit for privilege escalation
    polkit.enable = true;

    # GNOME Keyring
    gnome.gnome-keyring.enable = true;

    # Desktop portal
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

    # Hardware acceleration is now managed in graphics.nix

    # Bluetooth
    blueman.enable = true;

    # Firmware updater
    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
    };

    # Preload for faster application startup
    preload = {
      enable = false; # Can use significant RAM
    };

    # System profiler
    sysprof.enable = false;

    # AppArmor
    apparmor = {
      enable = false;
      killUnconfinedConfinables = false;
    };

    # Flatpak
    flatpak.enable = true;

    # Steam hardware support
    hardware.steam-hardware.enable = true;

    # USB automounting
    devmon.enable = true;

    # Resolved for DNS
    resolved = {
      enable = true;
      domains = [ "~." ];
      fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
      dnssec = "allow-downgrade";
    };
  };

  # Additional system-wide services via systemd
  systemd.services = {
    # Custom cleanup service
    meowrch-cleanup = {
      description = "Meowrch system cleanup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "meowrch-cleanup" ''
          # Clean package cache
          ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 7d
          
          # Clean journal logs
          ${pkgs.systemd}/bin/journalctl --vacuum-time=7d
          
          # Clean temporary files
          ${pkgs.findutils}/bin/find /tmp -type f -atime +3 -delete || true
          ${pkgs.findutils}/bin/find /var/tmp -type f -atime +7 -delete || true
        '';
      };
      startAt = "weekly";
    };

    # Fix permissions service
    meowrch-fix-permissions = {
      description = "Fix Meowrch permissions";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "fix-permissions" ''
          # Fix audio group permissions
          ${pkgs.coreutils}/bin/chmod 664 /dev/snd/* || true
          
          # Fix video group permissions  
          ${pkgs.coreutils}/bin/chmod 664 /dev/dri/* || true
          
          # Fix input group permissions
          ${pkgs.coreutils}/bin/chmod 664 /dev/input/* || true
        '';
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udev-settle.service" ];
    };
  };

  # Systemd user services
  systemd.user.services = {
    # User cleanup service
    meowrch-user-cleanup = {
      description = "Meowrch user cleanup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "user-cleanup" ''
          # Clean user cache
          ${pkgs.findutils}/bin/find $HOME/.cache -type f -atime +7 -delete || true
          
          # Clean browser cache (if too large)
          if [ -d "$HOME/.cache/mozilla" ]; then
            ${pkgs.coreutils}/bin/du -sh "$HOME/.cache/mozilla" | ${pkgs.gawk}/bin/awk '$1 ~ /G/ && $1 > 1 {exit 1}'
            if [ $? -ne 0 ]; then
              ${pkgs.findutils}/bin/find "$HOME/.cache/mozilla" -type f -atime +3 -delete || true
            fi
          fi
        '';
      };
      startAt = "daily";
    };
  };

  # Enable systemd user services
  systemd.user.startServices = "sd-switch";

  # System timer for maintenance
  systemd.timers = {
    meowrch-maintenance = {
      description = "Meowrch system maintenance timer";
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      wantedBy = [ "timers.target" ];
    };
  };

  # Enable important services by default
  systemd.targets.multi-user.wants = [
    "meowrch-fix-permissions.service"
  ];
}