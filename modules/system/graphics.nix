{ config, pkgs, lib, ... }:

{
  # Graphics Configuration - AMD focused
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      # AMD GPU drivers
      mesa
      amdvlk

      # Video acceleration
      libva
      libva-utils
      libdrm

      # Graphics Buffer Manager and mesa libraries
      mesa

      # Vulkan support
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
      amdvlk
    ];
  };

  # Hardware acceleration
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Scanner support
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplip
      sane-airscan
    ];
  };

  # AMD Graphics (Primary)
  boot.initrd.kernelModules = [ "amdgpu" ];
  # X11 video drivers only if X11 is enabled
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "amdgpu" ];

  # AMD GPU environment variables
  environment.variables = {
    VDPAU_DRIVER = "radeonsi";
    LIBVA_DRIVER_NAME = "radeonsi";
    AMD_VULKAN_ICD = "RADV";
  };

  # Gaming optimization (Steam configured in main configuration.nix)
  programs.gamemode.enable = true;

  # Graphics libraries and tools
  environment.systemPackages = with pkgs; [
    # Graphics utilities
    glxinfo
    vulkan-tools
    gpu-viewer
    mesa-demos

    # Performance monitoring
    mangohud
    goverlay
    radeontop
    amdgpu_top

    # Wayland graphics
    wlr-randr
    wayland-utils

    # Debugging tools
    renderdoc
    apitrace

    # Graphics libraries
    libGL
    libGLU
    mesa

    # Wayland development
    wayland
    wayland-protocols

    # Graphics benchmarking
    glmark2

    # Additional graphics dependencies for Hyprland
    seatd
    libinput
    libxkbcommon
    xorg.libxcb
    pipewire
    libgbm
  ];

  environment.extraPkgConfigPackages = with pkgs; [
    mesa
  ];

  # Kernel parameters for AMD Graphics
  boot.kernelParams = [
    # AMD Graphics optimization
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.gpu_recovery=1"
    "amdgpu.deep_color=1"
    "amdgpu.dc=1"

    # General graphics
    "quiet"
    "splash"
  ];

  # Graphics-related services
  services.xserver.enable = lib.mkDefault false;

  # Environment variables for graphics
  environment.sessionVariables = {
    # Wayland
    NIXOS_OZONE_WL = "1";

    # AMD Graphics acceleration
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    AMD_VULKAN_ICD = "RADV";

    # Gaming optimizations
    mesa_glthread = "true";
    AMD_DEBUG = "nohyperz";
  };

  # Hardware video acceleration - removed Intel specific overrides

  # Font rendering handled by theming.nix

  # DRM/KMS configuration
  boot.kernelModules = [
    "drm"
    "drm_kms_helper"
  ];

  # Systemd graphics services
  systemd.tmpfiles.rules = [
    "d /tmp/.X11-unix 1777 root root 10d"
    "d /tmp/.ICE-unix 1777 root root 10d"
  ];

  # Graphics optimization for gaming
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # For gaming compatibility
  };
}
