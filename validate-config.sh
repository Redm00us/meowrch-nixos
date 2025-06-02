#!/usr/bin/env bash

# Meowrch NixOS Configuration Validation Script
# This script helps validate your NixOS configuration before applying it

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "flake.nix" ]]; then
    print_error "flake.nix not found. Please run this script from the NixOS configuration directory."
    exit 1
fi

print_status "🐱 Meowrch NixOS Configuration Validator"
echo

# Check if nix is available
if ! command -v nix &> /dev/null; then
    print_error "Nix is not installed or not in PATH"
    exit 1
fi

# Check flake syntax
print_status "Checking flake syntax..."
if nix flake show --json > /dev/null 2>&1; then
    print_success "Flake syntax is valid"
else
    print_error "Flake syntax error detected"
    exit 1
fi

# Check for common configuration issues
print_status "Checking for common configuration issues..."

# Check for systemd.user.startServices (invalid option)
if grep -r "systemd\.user\.startServices" . --include="*.nix" > /dev/null 2>&1; then
    print_error "Found invalid systemd.user.startServices option (this is home-manager specific)"
    echo "  This option should be removed from NixOS configuration files"
else
    print_success "No invalid systemd.user.startServices found"
fi

# Check for duplicate module imports
print_status "Checking for duplicate module imports..."
if grep -A 20 "imports = \[" configuration.nix | grep -E "(audio|bluetooth|graphics|networking|security|services|fonts)\.nix" > /dev/null 2>&1; then
    print_warning "Potential duplicate module imports detected in configuration.nix"
    echo "  These modules are already imported in flake.nix"
else
    print_success "No duplicate module imports detected"
fi

# Check hardware-configuration.nix
if [[ -f "hardware-configuration.nix" ]]; then
    print_success "hardware-configuration.nix found"
else
    print_warning "hardware-configuration.nix not found"
    echo "  This file should be generated during NixOS installation"
    echo "  You can generate it with: nixos-generate-config"
fi

# Validate flake structure
print_status "Validating flake structure..."
if nix flake check 2>&1 | grep -q "error:"; then
    print_error "Flake check failed:"
    nix flake check
    exit 1
else
    print_success "Flake structure is valid"
fi

# Check for required inputs
print_status "Checking flake inputs..."
required_inputs=("nixpkgs" "home-manager" "hyprland")
for input in "${required_inputs[@]}"; do
    if grep -q "$input" flake.nix; then
        print_success "Input '$input' found"
    else
        print_error "Required input '$input' not found in flake.nix"
    fi
done

# Check system configuration
print_status "Checking system configuration..."
if grep -q 'system = "x86_64-linux"' flake.nix; then
    print_success "System architecture specified"
else
    print_warning "System architecture not clearly specified"
fi

# Check for NixOS 25.05 compatibility
if grep -q "25.05" flake.nix; then
    print_success "NixOS 25.05 version specified"
else
    print_warning "NixOS version not clearly specified"
fi

# Final validation attempt
print_status "Performing final validation..."
if nix build .#nixosConfigurations.meowrch.config.system.build.toplevel --dry-run > /dev/null 2>&1; then
    print_success "Configuration builds successfully (dry-run)"
else
    print_error "Configuration failed to build"
    echo "  Run the following command for detailed error information:"
    echo "  nix build .#nixosConfigurations.meowrch.config.system.build.toplevel --dry-run"
    exit 1
fi

echo
print_success "🎉 Configuration validation completed successfully!"
echo
print_status "To apply this configuration:"
print_status "  sudo nixos-rebuild switch --flake .#meowrch"
echo
print_status "To update inputs:"
print_status "  nix flake update"
echo
print_status "To check what will be built:"
print_status "  nixos-rebuild dry-build --flake .#meowrch"