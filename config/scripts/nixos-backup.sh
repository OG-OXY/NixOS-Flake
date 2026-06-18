#!/usr/bin/env bash
set -e

# 1. Define your out-of-repo safety backup directory
BACKUP_DIR="$HOME/.config/nixos-backups/$(date +%Y-%m-%d_%H-%M)"

echo "📦 Copying files to independent safety backup: $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
# Copy only your core configuration assets, skipping the Projects cache folder
cp -r $HOME/nixos/*.nix $HOME/nixos/config "$BACKUP_DIR/"

echo "🧹 Formatting Nix files with nixfmt..."
# Runs nixfmt instantly on your config files without installing it permanently
nix run nixpkgs#nixfmt -- $HOME/nixos/*.nix

echo "⚙️ Rebuilding NixOS system via your home directory layout..."
sudo nixos-rebuild switch --flake /etc/nixos
