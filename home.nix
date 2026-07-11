{ config, pkgs, lib, inputs, ... }: {

  home.stateVersion = "26.11";
  xdg.configFile = {
    "ghostty/config".text = ''
      theme = GruvBoxDark
      font-size = 22
      background-opacity = 0.95
    '';
  };
  imports = [
    ./modules/home/fish.nix
    ./modules/home/ghostty.nix
    ./modules/home/tmux.nix
    ./modules/home/yazi.nix
    ./modules/home/atuin.nix
    ./modules/home/rbw.nix
  ];
  programs.herdr.enable = true;
  programs.devenv.enable = true;
  programs.home-manager.enable = true;
}
