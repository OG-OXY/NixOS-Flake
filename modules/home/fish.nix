{ config, pkgs, ... }: {

  programs.fish = {
    enable = true;
    functions = {
      y = {
        body = ''
          set -l tmp (mktemp -t "yazi-cwd.XXXXX")
          command yazi $argv --cwd-file="$tmp"
          if set -l cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };
      gback = {
      description = "Safely undo the last Git commit but keep file changes";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
          echo (set_color red)"❌ Error: Not a git repository!"(set_color normal)
          return 1
        end
        echo (set_color yellow)"⏪ Undoing last commit safely (keeping modifications)..."(set_color normal)       git reset --soft HEAD~1
        echo (set_color green)"✨ Done! Check 'git status' to see your uncommitted files."(set_color normal)
	'';
      };
    };

    shellAbbrs = {
      sudo = "doas";
      su = "doas fish";
      ls = "ls -a";
      cds = "cd ~/NixOS/nixos";
      ga = "git add -A";
      gc = "git commit -m \"";
      gp = "git push -u origin master";
      gpf = "git push -u --force origin master";
      yz = "yazi";
      nv = "nvf";
      snv = "sudoedit nvf";
      v = "vis";
      sv = "sudoedit vis";
      sy = "doas yazi";
      nrs = "sudo nixos-rebuild switch --flake .#nixos";
      nrsu = "sudo nixos-rebuild switch --upgrade --flake .#nixos";
      nrt = "sudo nixos-rebuild test --flake .#nixos";
      nrtu = "sudo nixos-rebuild test --upgrade --flake .#nixos";
      nrvm = "sudo nixos-rebuild build-vm --flake .#nixos";
      vm = "./result/bin/run-nixos-vm";
      nb = "nix-backup";
      nub = "nix-upgrade-backup";
      ts = "doas tailscale up";
    };

    interactiveShellInit = ''
      set -g fish_greeting "Welcome to NixOS!"
      set -g fish_handle_reflow 1

      fastfetch
      starship init fish | source
      if test "$USER" = "root"
        set -gx ATUIN_CONFIG_DIR "/root/.config/atuin"
          else
        set -gx ATUIN_CONFIG_DIR "$HOME/.config/atuin"
      end
      if type -q direnv
          direnv hook fish | source
      end
      fish_add_path -p "$HOME/.local/bin"
    '';

    plugins = with pkgs.fishPlugins; [
      { name = "bass"; src = bass.src; }
      { name = "fzf-fish"; src = fzf-fish.src; }
      { name = "autopair"; src = autopair.src; }
      { name = "sponge"; src = sponge.src; }
      { name = "done"; src = done.src; }
      { 
        name = "abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "v0.7.0"; # Verified latest tag
          sha256 = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
      }
      {
        name = "fish-you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "paysonwallach";
          repo = "fish-you-should-use";
          rev = "master";
          sha256 = "sha256-MmGDFTgxEFgHdX95OjH3jKsVG1hdwo6bRht+Lvvqe5Y=";
        };
      }
    ];
  };

  home.sessionVariables = {
    EDITOR = "nvf";
    VISUAL = "nvf";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
