{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.stateVersion = "26.11";

  imports = [ ../../home.nix ];

  home.file = {
    ".config/starship.toml".source = ../../config/starship/starship-root.toml;
  };
}
