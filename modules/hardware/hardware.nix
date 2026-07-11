{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];
  
  boot.initrd.kernelModules = [ ];
  
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelModules = [
    "kvm-amd"
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
    "i2c-dev"
    "i2c-piix4"
  ];

  boot.kernelParams = [
    "processor.max_cstate=0"
    "amd_idle.max_cstate=0"
    "amd_iommu=on"
    "iommu=pt"
  ];

  boot.kernel.sysctl = {
    "kernel.sysrq" = true;
    "vm.swappiness" = 100;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "fs.inotify.max_user_watches" = 524288;
  };
  
  boot.extraModulePackages = [ ];
  
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2990dbf8-472f-4656-be4f-3c2363bf7482";
    fsType = "ext4";
  };
  
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DC0A-2C5E";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  
  fileSystems."/2TB-HDD" = {
    device = "/dev/disk/by-uuid/366beafd-26b6-4fd7-bd10-23795514d3fb";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/ventoy" = {
    device = "/dev/disk/by-uuid/4E21-0000";
    fsType = "exfat";
  };

  fileSystems."/gentoo" = {
    device = "/dev/disk/by-uuid/0eee5a7c-ed6b-473e-8063-86994222e03d";
    fsType = "ext4";
  };
  
  fileSystems."/gentoo/boot" = {
    device = "/dev/disk/by-uuid/CB66-8A42";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };


}
