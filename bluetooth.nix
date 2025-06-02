{ config, pkgs, lib, ... }:

{
  # Bluetooth Configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;
    
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        KernelExperimental = true;
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
        FastConnectable = true;
      };
      
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 7;
        ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
      };
      
      LE = {
        MinConnectionInterval = 7;
        MaxConnectionInterval = 9;
        ConnectionLatency = 0;
        ConnectionSupervisionTimeout = 720;
        Autoconnect = true;
      };
      
      GATT = {
        ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
        AutoEnable = true;
      };
    };
  };

  # Bluetooth services
  services = {
    # Bluetooth manager
    blueman.enable = true;
    
    # D-Bus configuration for Bluetooth
    dbus.packages = with pkgs; [ bluez blueman ];
    
    # udev rules for Bluetooth devices
    udev.packages = with pkgs; [ bluez ];
  };

  # Bluetooth packages
  environment.systemPackages = with pkgs; [
    # Bluetooth utilities
    bluez
    bluez-tools
    bluez-alsa
    blueman
    
    # Audio over Bluetooth
    pulseaudio-modules-bt
    
    # GUI managers
    blueberry
    
    # Command line tools
    bluetuith
    
    # Debugging tools
    btmon
    hcitool
    rfkill
    
    # Audio testing
    pactl
    bluetoothctl
  ];

  # User permissions for Bluetooth
  users.users.redm00us.extraGroups = [ "bluetooth" ];

  # Systemd services for Bluetooth
  systemd.services.bluetooth = {
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.bluez}/libexec/bluetooth/bluetoothd --noplugin=sap"
      ];
    };
  };

  # Enable Bluetooth audio support
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];

  # PipeWire Bluetooth configuration
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
        ["bluez5.codecs"] = "[ sbc sbc_xq aac ldac aptx aptx_hd aptx_ll aptx_ll_duplex faststream faststream_duplex ]",
        ["bluez5.default.rate"] = 48000,
        ["bluez5.default.channels"] = 2,
      }
    '')
  ];

  # Bluetooth kernel modules
  boot.kernelModules = [
    "bluetooth"
    "btusb"
    "rfcomm"
    "bnep"
    "btrtl"
    "btbcm"
    "btintel"
  ];

  # Bluetooth firmware
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  # Power management for Bluetooth
  powerManagement.enable = true;
  
  # udev rules for Bluetooth power management
  services.udev.extraRules = ''
    # Disable USB autosuspend for Bluetooth devices
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", TEST=="power/control", ATTR{power/control}="on"
    
    # Bluetooth device permissions
    KERNEL=="rfkill", SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", TAG+="uaccess"
    
    # Allow users in bluetooth group to control Bluetooth adapters
    SUBSYSTEM=="bluetooth", TAG+="uaccess"
    KERNEL=="hci[0-9]*", TAG+="uaccess"
  '';

  # Bluetooth security settings
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.passwd.enableGnomeKeyring = true;

  # Auto-start Bluetooth manager
  systemd.user.services.blueman-applet = {
    description = "Blueman applet";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Environment variables for Bluetooth
  environment.sessionVariables = {
    # Bluetooth audio quality
    BLUETOOTH_A2DP_CODEC = "aptx";
    BLUETOOTH_A2DP_BITPOOL = "53";
  };

  # Bluetooth configuration files
  environment.etc = {
    "bluetooth/audio.conf".text = ''
      [General]
      Enable=Source,Sink,Media,Socket
      Disable=Headset
      
      [A2DP]
      SBCFreq=44100,48000
      SBCXQ=true
      
      [AVRCP]
      Class=0x000100
      Title=%s
      Artist=%s
      Album=%s
      Genre=%s
      NumberOfTracks=%s
      TrackNumber=%s
      TrackDuration=%s
    '';
    
    "bluetooth/input.conf".text = ''
      [General]
      UserspaceHID=true
      ClassicBondedOnly=false
      LEAutoConnect=true
    '';
    
    "bluetooth/network.conf".text = ''
      [General]
      DisableSecurity=false
    '';
  };

  # Bluetooth mesh support
  boot.kernelParams = [
    "bluetooth.disable_ertm=1"
    "bluetooth.disable_esco=1"
  ];

  # Auto-connect to known devices
  systemd.user.services.bluetooth-autoconnect = {
    description = "Auto-connect to Bluetooth devices";
    after = [ "bluetooth.service" ];
    wants = [ "bluetooth.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "bluetooth-autoconnect" ''
        sleep 5
        ${pkgs.bluez}/bin/bluetoothctl power on
        sleep 2
        ${pkgs.bluez}/bin/bluetoothctl connect-all || true
      '';
    };
  };

  # Bluetooth troubleshooting tools are included above
}