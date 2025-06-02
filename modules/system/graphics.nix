{ config, pkgs, lib, ... }:

{
  # Graphics Configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    
    extraPackages = with pkgs; [
      # Intel Graphics
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime
      
      # AMD GPU drivers
      mesa.drivers
      amdvlk
      
      # ROCm for compute
      rocm-opencl-icd
      rocm-opencl-runtime
      
      # Video acceleration
      libva
      libva-utils
      libdrm
      
      # Vulkan support
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
    
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
      intel-media-driver
      mesa.drivers
      driversi686Linux.amdvlk
    ];
  };

  # Hardware acceleration
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # AMD Graphics (Primary)
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # AMD GPU environment variables
  environment.variables = {
    VDPAU_DRIVER = "radeonsi";
    LIBVA_DRIVER_NAME = "radeonsi";
    AMD_VULKAN_ICD = "RADV";
  };

  # NVIDIA Graphics Support
  hardware.nvidia = {
    modesetting.enable = lib.mkDefault true;
    powerManagement.enable = lib.mkDefault false;
    powerManagement.finegrained = lib.mkDefault false;
    open = lib.mkDefault false;
    nvidiaSettings = lib.mkDefault true;
    
    # Use the latest driver package
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    
    # Enable NVIDIA PRIME for laptops with hybrid graphics
    prime = {
      # sync.enable = true;
      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };
      
      # Find bus IDs with: lspci | grep -E "(VGA|3D)"
      # intelBusId = "PCI:0:2:0";
      # nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Gaming and graphics optimization
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

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
    
    # Image and video acceleration
    intel-gpu-tools
    
    # Wayland graphics
    wlr-randr
    wayland-utils
    
    # Debugging tools
    renderdoc
    apitrace
    
    # Graphics libraries
    libGL
    libGLU
    
    # Wayland development
    wayland
    wayland-protocols
    
    # Graphics benchmarking
    unigine-valley
    glmark2
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
  services = {
    # Graphics compositor support
    xserver = {
      enable = lib.mkDefault false; # We use Wayland
      excludePackages = with pkgs; [ xterm ];
    };
    
    # GPU switching for NVIDIA Optimus
    # switcherooControl.enable = true;
  };

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

  # Graphics permissions (user groups defined in main configuration.nix)

  # Hardware video acceleration
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # Font rendering optimization
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.rgba = "rgb";
      subpixel.lcdfilter = "default";
    };
  };

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