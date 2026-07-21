{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home = {
    username = "root";
    homeDirectory = "/root";
  };

  imports = [ ../../home.nix ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship-root.toml);
  };
}
