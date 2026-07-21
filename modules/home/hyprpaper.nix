{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  wallpaperDirPath = "/home/ty/Media/Pictures/wpapers";
  dirContents = builtins.readDir wallpaperDirPath;
  allWallpapers = lib.mapAttrsToList (name: type: "${wallpaperDirPath}/${name}") (
    lib.filterAttrs (name: type: type == "regular") dirContents
  );
  defaultWallpaper = "${wallpaperDirPath}/gruvbox-rainbow-nix.png";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = "allWallpapers";
      wallpaper = [
        ",${defaultWallpaper}"
      ];
    };
  };
}
