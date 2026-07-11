{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.stateVersion = "26.11";
  home.file = {
    ".config/ghostty".source = ./config/ghostty;
    ".config/fish".source = ./config/fish;
    ".config/tmux".source = ./config/tmux;
    ".config/yazi".source = ./config/yazi;
    ".config/btop".source = ./config/btop;
    ".config/atuin/config.toml".source = ./config/atuin/config.toml;
  };
  home.packages = [
    (pkgs.writeShellScriptBin "nix-backup" (builtins.readFile ./config/scripts/nix-backup.sh))
  ];

  programs.fish = {
    plugins = with pkgs.fishPlugins; [
      {
        name = "bass";
        src = bass.src;
      }
      {
        name = "bax";
        src = pkgs.fetchFromGitHub {
          owner = "vanyaxar";
          repo = "bax";
          rev = "master";
          sha256 = "sha256-R3hVjY2F+8w8w0Y7Z5UvN8RzQW2Z5X1Y2Z3W4V5U6T7=";
        };
      }
      {
        name = "fzf-fish";
        src = fzf-fish.src;
      }
      {
        name = "autopair";
        src = autopair.src;
      }
      {
        name = "sponge";
        src = sponge.src;
      }
      {
        name = "done";
        src = done.src;
      }
      {
        name = "abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "v0.7.0";
          sha256 = "sha256-6gD710S9w76vMkwS9P8Ue2kY4QxP8ZkwMkwS9P8Ue2k=";
        };
      }
    ];
  };

  programs.tmux = {
    shell = "${pkgs.fish}/bin/fish";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      resurrect
      continuum
    ];
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "ogoxy.yt@gmail.com";
    };
  };

  programs.devenv.enable = true;
}
