{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  home.stateVersion = "26.11";
  xdg.configFile = {
    "ghostty/config".text = ''
      theme = GruvBoxDark
      background-opacity = 1.0
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

  #programs.waybar.enable = true;
  programs = {
    waybar = {
      enable = true;
      systemd.enable = true;
    };
    herdr.enable = true;
    devenv.enable = true;
    home-manager.enable = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/Media/Pictures/wpapers/" ];
      wallpaper = [ "~/Media/Pictures/wpapers/gruvbox-rainbow-nix.png" ];
    };
  };
}
