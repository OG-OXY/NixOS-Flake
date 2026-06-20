# Help is in configuration.nix(5) man page, https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./amd.nix
    ./nvidia.nix
  ];

  # Login shell.
  users.users.ty.shell = pkgs.fish;
  users.users.root.shell = pkgs.fish;

  # Kernel PKG + parameters.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ];
  boot.kernelModules = [
    "kvm-amd"
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
  ];

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
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # User parameters.
  users.mutableUsers = true;
  users.users.ty = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "render"
      "input"
      "audio"
      "docker"
      "libvirtd"
      "vboxusers"
      "wireshark"
      "tcpdump"
    ];
    packages = with pkgs; [ ];
  };

  # NIX-PKG-Manager parameters.
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.enable = true;
  };

  # System parameters (Converted to relative path for Flake compliance)
  environment.etc."atuin/config.toml".source = ./config/atuin/config.toml;

  # Install system PKGS.
  environment.systemPackages =
    (with pkgs; [
      ghostty
      rofi
      brave
      wget
      pfetch
      scrot
      maim
      slop
      xclip
      qalculate-gtk
      pavucontrol
      xwallpaper
      fastfetch
      btop
      dysk
      tree
    ])
    ++ [
      inputs.zen-browser.packages.${pkgs.system}.default
    ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Optional: Enable experimental features for better codec support
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # X11 + WM.
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --output DP-1 --zoom /home/ty/Media/Pictures/wpapers/gruvbox-rainbow-nix.png --output HDMI-1 --zoom /home/ty/Media/Pictures/wpapers/gruvbox-rainbow-nix.png
      xset r rate 200 45 &
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
    alsa.enable = true;
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

  # Udev rule 59-vial.rules (allow vial permissions for all devices).
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "keychron-udev-rules";
      destination = "/etc/udev/rules.d/50-keychron.rules";
      text = ''
                # 1. KEYCHRON KEYBOARDS & RECEIVERS (Factory ZMK, VIA, or QMK Modes)
                
        	# Target Keychron's Vendor ID globally for raw hidraw and USB permissions
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
                SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
                # 2. VIAL COMPATIBILITY LAYER
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

              
                # 3. UNIVERSAL MOUSE / POINTER INPUTS
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="*input*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

                # 4. FLASHING & BOOTLOADER MODES (For switching between ZMK & QMK/Vial)
              
                # STM32 DFU Bootloader
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0660", GROUP="users", TAG+="uaccess"
              
                # APM32 DFU Bootloader (Common on newer Keychron hardware)
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="314b", ATTRS{idProduct}=="0106", MODE="0660", GROUP="users", TAG+="uaccess"
              
                # Raspberry Pi RP2040 Bootloader (Mass storage / picoboot mode)
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", MODE="0660", GROUP="users", TAG+="uaccess"
      '';
    })
  ];

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
  system.systemBuilderCommands = ''
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
