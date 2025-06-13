# 🐱 Meowrch NixOS 25.05 Installation & Fix Instructions

This guide will help you properly install and configure your NixOS 25.05 system with the Meowrch configuration.

## 🚨 Critical Issues Fixed

### 1. Missing Hardware Configuration
The main error you encountered was due to missing `hardware-configuration.nix`. This file is essential for NixOS to know how to boot your system.

### 2. Deprecated Options Updated
- Fixed `services.resolved.dnssec` from string to boolean
- Removed invalid `services.logind.enable` references
- Updated service configurations for NixOS 25.05 compatibility

## 📋 Prerequisites

1. **NixOS Live USB/ISO** - Boot from NixOS installation media
2. **Internet Connection** - Required for downloading packages
3. **Disk Space** - At least 20GB free space recommended

## 🛠️ Installation Steps

### Step 1: Boot NixOS Live Environment

Boot from your NixOS installation media and connect to the internet:

```bash
# Connect to WiFi (if needed)
sudo systemctl start wpa_supplicant
sudo wpa_cli
> add_network
> set_network 0 ssid "YourWiFiName"
> set_network 0 psk "YourWiFiPassword"
> enable_network 0
> quit

# Test internet connection
ping -c 3 google.com
```

### Step 2: Partition Your Disk

Replace `/dev/sdX` with your actual disk (check with `lsblk`):

```bash
# Example partitioning scheme for UEFI systems
sudo parted /dev/sdX -- mklabel gpt
sudo parted /dev/sdX -- mkpart root ext4 512MB -8GB
sudo parted /dev/sdX -- mkpart swap linux-swap -8GB 100%
sudo parted /dev/sdX -- mkpart ESP fat32 1MB 512MB
sudo parted /dev/sdX -- set 3 esp on

# Format partitions
sudo mkfs.ext4 -L nixos /dev/sdX1
sudo mkswap -L swap /dev/sdX2
sudo mkfs.fat -F 32 -n boot /dev/sdX3

# Enable swap
sudo swapon /dev/sdX2
```

### Step 3: Mount File Systems

```bash
# Mount root partition
sudo mount /dev/disk/by-label/nixos /mnt

# Create boot directory and mount
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

### Step 4: Generate Hardware Configuration

```bash
# Generate hardware configuration
sudo nixos-generate-config --root /mnt

# This creates /mnt/etc/nixos/hardware-configuration.nix
```

### Step 5: Clone Meowrch Configuration

```bash
# Clone this repository to /mnt/etc/nixos
cd /mnt/etc/nixos
sudo rm -f configuration.nix  # Remove default config
sudo git clone https://github.com/your-username/nixos-config.git .

# Or if you have the files locally, copy them:
sudo cp -r /path/to/your/NixOS-25.05/* /mnt/etc/nixos/
```

### Step 6: Fix Hardware Configuration

Edit the generated hardware configuration:

```bash
sudo nano /mnt/etc/nixos/hardware-configuration.nix
```

Make sure it includes proper file systems. Example:

```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/YOUR-ROOT-UUID";
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/YOUR-BOOT-UUID";
  fsType = "vfat";
  options = [ "fmask=0022" "dmask=0022" ];
};

swapDevices = [
  { device = "/dev/disk/by-uuid/YOUR-SWAP-UUID"; }
];
```

Find your UUIDs with:
```bash
sudo blkid
```

### Step 7: Enable Flakes and Install

```bash
# Enable flakes temporarily
export NIX_CONFIG="experimental-features = nix-command flakes"

# Install NixOS
sudo nixos-install --flake .#meowrch

# Set root password when prompted
# Create user password
sudo nixos-enter --root /mnt
passwd redm00us
exit
```

### Step 8: Reboot and Enjoy

```bash
sudo reboot
```

## 🔧 Post-Installation Fixes

### If You Get File System Errors

1. **Check UUIDs are correct**:
   ```bash
   lsblk -f
   blkid
   ```

2. **Update hardware-configuration.nix with correct UUIDs**:
   ```bash
   sudo nano /etc/nixos/hardware-configuration.nix
   ```

3. **Rebuild configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .#meowrch
   ```

### If You Get Service Errors

1. **Run the validation script**:
   ```bash
   ./validate-config.sh
   ```

2. **Check system journal for errors**:
   ```bash
   journalctl -xe
   ```

3. **Test configuration without applying**:
   ```bash
   nixos-rebuild dry-build --flake .#meowrch
   ```

## 🎯 Fixing Existing Installation

If you already have a broken NixOS installation:

### 1. Boot from Live USB

Boot from NixOS installation media.

### 2. Mount Your System

```bash
# Find your partitions
lsblk

# Mount root partition
sudo mount /dev/sdXY /mnt
sudo mount /dev/sdXZ /mnt/boot  # If separate boot partition
```

### 3. Enter System

```bash
sudo nixos-enter --root /mnt
```

### 4. Fix Configuration

```bash
cd /etc/nixos

# Generate new hardware config if needed
nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Apply fixes from this guide
# Edit hardware-configuration.nix to have correct UUIDs and file systems
```

### 5. Rebuild

```bash
nixos-rebuild switch --flake .#meowrch
```

## 🐛 Common Issues & Solutions

### Issue: "The fileSystems option does not specify your root file system"

**Solution**: Check your `hardware-configuration.nix` file has:
```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/YOUR-ACTUAL-UUID";
  fsType = "ext4";  # or your file system type
};
```

### Issue: "services.logind.enable" error

**Solution**: Remove any `services.logind.enable = true;` lines - logind is always enabled in NixOS.

### Issue: "hardware.opengl" deprecated

**Solution**: Replace `hardware.opengl` with `hardware.graphics` in all config files.

### Issue: DNS resolution problems

**Solution**: Check `services.resolved.dnssec = true;` (not `"true"` string).

## ✅ Validation

After installation, validate your configuration:

```bash
# Run validation script
./validate-config.sh

# Test rebuild
sudo nixos-rebuild dry-build --flake .#meowrch

# Apply if everything looks good
sudo nixos-rebuild switch --flake .#meowrch
```

## 📚 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [NixOS Hardware Database](https://github.com/NixOS/nixos-hardware)

## 🆘 Getting Help

If you encounter issues:

1. Check the validation script output
2. Look at system logs: `journalctl -xe`
3. Test configuration: `nixos-rebuild dry-build --flake .#meowrch`
4. Join NixOS community forums or Discord

---

**Note**: This configuration is tested with NixOS 25.05. Make sure you're using the correct NixOS version and that all hardware-specific configurations match your actual hardware.