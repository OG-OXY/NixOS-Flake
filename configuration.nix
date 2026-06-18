# Help is in configuration.nix(5) man page, https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, self, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
  ];

  # Login shell.
  users.users.ty.shell = pkgs.fish;
  users.users.root.shell = pkgs.fish;

  # Kernel PKG + parameters.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];
  boot.kernelModules = [ "kvm-amd" "vfio" "vfio_iommu_type1" "vfio_pci" ];
  
  # Systemctl parameters.
  boot.kernel.sysctl = {    
    "kernel.sysrq" = true;
    "vm.swappiness" = 100;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "fs.inotify.max_user_watches" = 524288;
  }; 
  
  # Bootloader + GRUB parameters.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 15;
    };
  };
   
  # User account.
  security.sudo = {
    enable = true;
    extraRules = [{
      groups = [ "wheel" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];
  };

  # User parameters.
  users.mutableUsers = true;
  users.users.ty = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "render" "input" "audio" "docker" "libvirtd" "vboxusers" "wireshark" "tcpdump" ];
    packages = with pkgs; [];
  };
  
  # NIX-PKG-Manager parameters.
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

    # Garbage collection.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  
  # Networking PKGS + parameters.
  networking.hostName = "nixos"; 
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Install PKGS with system parameters.
  programs.firefox.enable = true;
  programs.tmux.enable = true;
  programs.fish.enable = true;
  programs.yazi.enable = true;
  programs.virt-manager.enable = true;
  programs.zoxide.enable = true;
  programs.atuin.enable = true;
  programs.starship.enable = true;
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "Ty";
      user.email = "ogoxy.yt@gmail.com";
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
    };
  };
  
  # System parameters (Converted to relative path for Flake compliance)
  environment.etc."atuin/config.toml".source = ./config/atuin/config.toml;

  # Install system PKGS.
  environment.systemPackages = with pkgs; [
    ghostty
    rofi
    vial
    wget
    fastfetch
    btop
    pfetch
    xwallpaper
    scrot
    maim
    slop
    xclip
    dysk
    tree
  ];
  
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.enable = true;
  };

  # X11 + WM.
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --output DP-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruvbox-nix.png --output HDMI-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruvbox-nix.png
      xset r rate 200 35 &
    '';
  };
  
  # Compositor.
  services.picom = {
    enable = true;
    settings = {
      fading = true;
      shadows = true;
      blur = true;
      active-opacity = 1.0;
      inactive-opacity = 0.95;
      corner-radius = 0;
    };
  };
  
  # Sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  
  # Zram swap.
  services.zram-generator = {
    enable = true;
    settings = {
      zram0 = {
        compression-algorithm = "lz4";
        zram-size = 16384;
      };
    };
  };

  # OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no"; 
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  services.udev.packages = with pkgs; [ vial ];

  # Udev rules.
  services.udev.extraRules = ''
    # Keychron V3 8K
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0f30", MODE="0660", GROUP="users", TAG+="uaccess" TAG+="udev-acl"
  '';
  
  # NixOS VM sandbox.
  virtualisation.vmVariant = {
    users.users.ty.password = "test";
    users.users.root.password = "test";
    virtualisation = {
      memorySize = 8192;
      cores = 8;
      qemu.options = [ "-device virtio-vga-gl -display gtk,gl=on" ];
    };
  };
  
  # Virt-Manager VM libvirtd hook + hardware virtualisation.
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
    };
  };
  
  # Podman VM.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Links backup snapshot into system generation (serves the purpose of system.copySystemConfiguration = true;).
  system.extraSystemBuilderCmds = ''
    ln -s ${self} $out/src
  '';

  # Injects git commit hash into the system version metadata
  system.configurationRevision = lib.mkIf (self ? rev) self.rev;

  # Time zone.
  time.timeZone = "America/New_York";
  
  # Disabled PKGS.
  programs.nano.enable = false;
  services.libinput.enable = false;
  services.printing.enable = false;
  
  # Origin NixOS install version, NEVER CHANGE.
  system.stateVersion = "26.05";
}
