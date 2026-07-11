{ config, pkgs, ... }: {
  home.packages = [
    # 1. The Full Upgrade + Backup Loop
    (pkgs.writeScriptBin "nix-upgrade-backup" ''
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

      echo "🧹 Formatting Nix files with nixfmt..."
      ${pkgs.nixfmt}/bin/nixfmt *.nix

      echo "⚡ Staging formatted elements and the new lockfile to Git..."
      git add -A

      echo "⚙️ Rebuilding and switching NixOS system..."
      sudo nixos-rebuild switch --flake .#nixos

      # Reclaim user ownership of files sudo or the builder modified.
      echo "🔑 Restoring file ownership permissions..."
      sudo chown -R ty:users /home/ty

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

      # 1. Safety backup directory.
      BACKUP_DIR="$HOME/.nix-backup/$(date +%Y-%m-%d_%H-%M)"
      echo "📦 Compiling configuration snapshot to $BACKUP_DIR..."
      mkdir -p "$BACKUP_DIR/.config" "$BACKUP_DIR/.local/bin" "$BACKUP_DIR/NixOS/nixos"

      # Core directory copying routines
      [ -d "$HOME/.local/bin" ] && cp -R $HOME/.local/bin/* "$BACKUP_DIR/.local/bin/" 2>/dev/null || true
      [ -d "$HOME/NixOS/nixos" ] && cp -R $HOME/NixOS/nixos/* "$BACKUP_DIR/NixOS/nixos/" 2>/dev/null || true
      [ -d "$HOME/.config" ] && cp -R $HOME/.config/* "$BACKUP_DIR/.config/" 2>/dev/null || true

      echo "✨ SYSTEM UPGRADE AND BACKUP SEQUENCE COMPLETED"
    '')

    # 2. The Standalone Backup Utility (Excludes Upgrading)
    (pkgs.writeScriptBin "nix-backup" ''
      #!/usr/bin/env bash
      set -e

      # SAFETY GUARD: Detect root execution, safely drop to 'ty', and re-run
      if [ "$EUID" -eq 0 ]; then
          echo "⚠️ Warning: Script executed as root or via sudo."
          echo "🔒 Dropping privileges and re-running as user 'ty'..."
          
          exec sudo -i -u ty direnv exec . "$0" "$@" || exit 1
      fi

      # 1. Safety backup directory.
      BACKUP_DIR="$HOME/.nix-backup/$(date +%Y-%m-%d_%H-%M)"
      echo "📦 Compiling configuration snapshot to $BACKUP_DIR..."
      mkdir -p "$BACKUP_DIR/.config" "$BACKUP_DIR/.local/bin" "$BACKUP_DIR/NixOS/nixos"

      # Core directory copying routines
      [ -d "$HOME/.local/bin" ] && cp -R $HOME/.local/bin/* "$BACKUP_DIR/.local/bin/" 2>/dev/null || true
      [ -d "$HOME/NixOS/nixos" ] && cp -R $HOME/NixOS/nixos/* "$BACKUP_DIR/NixOS/nixos/" 2>/dev/null || true
      [ -d "$HOME/.config" ] && cp -R $HOME/.config/* "$BACKUP_DIR/.config/" 2>/dev/null || true

      echo "✨ STANDALONE BACKUP SEQUENCE COMPLETED SUCCESSFULLY"
    '')
  ];
}
