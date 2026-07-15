{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  home.stateVersion = "26.11";
  home.username = "ty";
  home.homeDirectory = "/home/ty";
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  imports = [ ../../home.nix ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship.toml);
  };
}
