{ config, pkgs, lib, inputs, ... }: {

  home.stateVersion = "26.11";
  home.username = "root";
  home.homeDirectory = "/root";
  
  imports = [ ../../home.nix ];
  
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship-root.toml);
  };
}
