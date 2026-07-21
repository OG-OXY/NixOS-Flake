{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home = {
    username = "ty";
    homeDirectory = "/home/ty";
  };

  imports = [ ../../home.nix ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship.toml);
  };
}
