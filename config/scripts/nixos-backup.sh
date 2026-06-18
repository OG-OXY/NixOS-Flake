#!/usr/bin/env bash
set -e

# Jump directly into your active configuration directory
cd "$HOME/nixos"

echo "🔄 Fetching latest channel inputs and updating flake.lock..."
# Re-pins upstream packages to their absolute newest commit hashes
nix flake update

# 1. Define your out-of-repo safety backup directory
BACKUP_DIR="$HOME/.nix-backup/$(date +%Y-%m-%d_%H-%M)"
echo "📦 Copying files to independent safety backup: $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# Copy your core configuration assets plus the newly generated lockfile
cp -r *.nix config flake.lock "$BACKUP_DIR/"

echo "🧹 Formatting Nix files with nixfmt..."
nix run nixpkgs#nixfmt -- *.nix

echo "⚡ Staging formatted elements and the new lockfile to Git..."
# Mandatory: Ensures the Flake engine registers the lockfile modifications
git add -A

echo "⚙️ Rebuilding and switching NixOS system..."
sudo nixos-rebuild switch --flake .#nixos

# FIX: Reclaim user ownership of any files sudo or the builder modified
echo "🔑 Restoring file ownership permissions..."
sudo chown -R ty:users .

# 2. Automated Git Commit and Push tracking
echo "📝 Checking for configuration changes to commit..."
if ! git diff-index --quiet HEAD --; then
    echo "💾 Changes detected. Committing lockfile and script mutations..."
    git commit -m "System auto-upgrade & lock refresh: $(date +'%Y-%m-%d %H:%M')"
    
    echo "🚀 Pushing configuration updates upstream..."
    git push
else
    echo "✅ No new updates or package upgrades detected. Tree is clean."
fi
