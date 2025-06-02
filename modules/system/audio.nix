{ config, pkgs, lib, ... }:

{
  # Audio Configuration
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Wireplumber configuration
    wireplumber.enable = true;
    
    # Additional audio packages
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };
  };

  # Audio packages
  environment.systemPackages = with pkgs; [
    # Audio control and utilities
    pavucontrol
    pamixer
    playerctl
    
    # Audio codecs and libraries
    pipewire
    wireplumber
    
    # Audio production tools (optional)
    # audacity
    # ardour
    
    # System sound theme
    sound-theme-freedesktop
  ];

  # User groups for audio
  users.groups.audio = {};
  users.users.meowrch.extraGroups = [ "audio" ];

  # Audio hardware support
  hardware = {
    # Enable audio hardware
    enableAllFirmware = true;
    
    # Bluetooth audio support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

  # PulseAudio configuration (disabled in favor of PipeWire)
  hardware.pulseaudio.enable = false;

  # System services for audio
  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];

  # Environment variables for audio
  environment.sessionVariables = {
    # PipeWire/WirePlumber
    PIPEWIRE_LATENCY = "32/48000";
  };

  # Audio permissions and security
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "99";
    }
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];

  # Kernel modules for audio
  boot.kernelModules = [
    "snd-seq"
    "snd-rawmidi"
  ];

  # ALSA configuration
  sound.enable = true;

  # Additional audio configuration for low latency
  boot.kernelParams = [
    "snd_hda_intel.power_save=0"
    "snd_hda_intel.power_save_controller=N"
  ];

  # Audio-related services
  services = {
    # Bluetooth for audio devices
    blueman.enable = true;
    
    # Audio device management
    udev.extraRules = ''
      # Audio device permissions
      SUBSYSTEM=="sound", GROUP="audio", MODE="0664"
      KERNEL=="controlC[0-9]*", GROUP="audio", MODE="0664"
    '';
  };

  # PipeWire configuration files
  environment.etc = {
    "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
      context.properties = {
          default.clock.rate          = 48000
          default.clock.quantum       = 32
          default.clock.min-quantum   = 32
          default.clock.max-quantum   = 32
      }
    '';
    
    "pipewire/pipewire-pulse.conf.d/92-low-latency.conf".text = ''
      context.modules = [
          {   name = libpipewire-module-protocol-pulse
              args = {
                  pulse.min.req          = 32/48000
                  pulse.default.req      = 32/48000
                  pulse.max.req          = 32/48000
                  pulse.min.quantum      = 32/48000
                  pulse.max.quantum      = 32/48000
              }
          }
      ]
      
      stream.properties = {
          node.latency             = 32/48000
          resample.quality         = 1
      }
    '';
  };
}