# nvidia.nix
{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    prime = {
      sync.enable = true;
      amdgpuBusId = "PCI:14:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
