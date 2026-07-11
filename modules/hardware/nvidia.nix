# nvidia.nix
{ config, pkgs, lib, inputs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    branch = "legacy_580";
  };
}
