# Help is in configuration.nix(5) man page, https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let # Home-Manager tarball version "26.11".
   home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
   imports =
     [ # Include the results of the hardware scan.
       ./hardware-configuration.nix
       (import "${home-manager}/nixos")
     ];

  # Home-Manager imports.
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.ty = import ./ty-home.nix;
  home-manager.users.root = import ./root-home.nix;
  
  # Login shell.
  users.users.ty.shell = pkgs.fish;
  users.users.root.shell = pkgs.fish;

  # Kernel PKG + parameters.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];
  boot.kernelModules = [ "kvm-amd" "vfio" "vfio_iommu_type1" "vfio_pci" ];
  # Systemctl parameters.
  boot.kernel.sysctl = {    
    "kernerl.sysrq" = true;
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
    # User only PKGS.
    packages = with pkgs; [

    ];
  };
  
  # NIX-PKG-Manager parameters.
  nix = {
    settings = {
      # Links duplicates to save space.
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
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # GDM displayManager.
  # services.displayManager.gdm.enable = true;
  
  # Keymaps in X11.
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  
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
      # Use SSH key for signing.
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
    };
  };
  
  # System parameters.
  environment.etc."atuin/config.toml".source = /etc/nixos/config/atuin/config.toml;

  # Install system PKGS.
  # https://search.nixos.org/ to find packages (and options).
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

  # Services.

  # X11 + WM.
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --output DP-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruv
box-nix.png --output HDMI-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruvbox
-nix.png
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
      PasswordAuthentication = false; # Disables insecure password logins.
      PermitRootLogin = "no";         # Blocks root user access.
    };
  };

  # Open firewall ports.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  services.udev.packages = with pkgs; [ vial ];

  # Udev rules.
  services.udev.extraRules = ''
    # Grant access to all hidraw devices
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", TAG+="uaccess" TAG+="udev-acl"
  '';
  
  # NixOS VM sandbox.
  virtualisation.vmVariant = {
    # Passwd = "test"
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

  # Copy NixOs (/run/current-system/configuration.nix).
  system.copySystemConfiguration = true;

  # Time zone.
  time.timeZone = "America/New_York";
  
  # Disabled PKGS.
  programs.nano.enable = false;
  services.libinput.enable = false;
  services.printing.enable = false;


  # Origin NixOS version, for compatibility. NEVER change its value. 
  # See "https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion".
  system.stateVersion = "26.05";
}
