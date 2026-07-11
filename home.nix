{ config, pkgs, lib, inputs, ... }: {

  home.stateVersion = "26.11"; 

  imports = [
    ./modules/home/fish.nix
    ./modules/home/ghostty.nix
    ./modules/home/tmux.nix
    ./modules/home/yazi.nix
    ./modules/home/atuin.nix
    ./modules/home/rbw.nix
  ];

  programs.devenv.enable = true;
  programs.home-manager.enable = true;
}
