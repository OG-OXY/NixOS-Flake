{ pkgs, lib, ... }:

let
  dirString = "/home/ty/Media/Pictures/wpapers";
  wallpaperDir = /. + dirString; # Converts string to a Nix path

  wallpapers = map (file: "${dirString}/${file}") (
    builtins.attrNames (builtins.readDir wallpaperDir)
  );

  defaultWallpaper = "${dirString}/gruvbox-rainbow-nix.png";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = wallpapers;
      wallpaper = [
        ",${defaultWallpaper}"
      ];
    };
  };
}
