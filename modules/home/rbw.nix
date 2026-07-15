{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "ogoxy.yt@gmail.com";
    };
  };
}
