# amd.nix
{ config, pkgs, ... }:

{
  # Load the AMD driver at the earliest possible boot stage
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Tell X11 and Wayland compositor backends to use the AMD driver
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Setup Mesa and hardware video acceleration (RADV handles Vulkan automatically)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for 32-bit gaming / Steam
  };
}
