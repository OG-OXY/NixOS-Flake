#!/usr/bin/env bash
set -e

# SAFETY GUARD: Detect root execution, safely drop to 'ty', and re-run
if [ "$EUID" -eq 0 ]; then
    echo "⚠️ Warning: Script executed as root or via sudo."
    echo "🔒 Dropping privileges and re-running as user 'ty'..."
    
    # Force execution as 'ty' with a pristine environment (-i)
    # The '|| exit 1' guarantees the script dies instantly if de-escalation fails
    exec sudo -i -u ty direnv exec . "$0" "$@" || exit 1
fi

# Jump directly into your active configuration directory
cd "$HOME/NixOS/nixos"

echo "🔄 Fetching latest channel inputs and updating flake.lock..."
nix flake update

# 1. Safety backup directory.
BACKUP_DIR="$HOME/.nix-backup/$(date +%Y-%m-%d_%H-%M)"
echo "📦 Copying files to independent safety backup: $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# Copy your core configuration assets plus the newly generated lockfile.
cp -r config hardware homes workspace *.nix *.lock "$BACKUP_DIR/"

# Copy user specific configurations that cant be configured through "config".
cp -r /home/ty/.config "$BACKUP_DIR/"

# Copy user scripts.
cp -r /home/ty/.local/bin "$BACKUP_DIR/"

echo "🧹 Formatting Nix files with nixfmt..."
nix run nixpkgs#nixfmt -- *.nix

echo "⚡ Staging formatted elements and the new lockfile to Git..."
git add -A

echo "⚙️ Rebuilding and switching NixOS system..."
sudo nixos-rebuild switch --flake .#nixos

# Reclaim user ownership of files sudo or the builder modified.
echo "🔑 Restoring file ownership permissions..."
sudo chown -R ty:users .

# 2. Git Commit and Push tracking.
echo "📝 Checking for configuration changes to commit..."
if ! git diff-index --quiet HEAD --; then
    echo "💾 Changes detected. Committing lockfile and script mutations..."
    git commit -m "System auto-upgrade & lock refresh: $(date +'%Y-%m-%d %H:%M')"
    
    echo "⏳ Waiting 10 seconds for NetworkManager to reconnect..."
    sleep 10
    
    echo "🚀 Pushing configuration updates upstream..."
    git push
else
    echo "✅ No new updates or package upgrades detected. Tree is clean."
fi
