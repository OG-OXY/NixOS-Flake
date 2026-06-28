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
    ./hardware/hardware.nix
    ./hardware/amd.nix
    ./hardware/nvidia.nix
  ];

  # Login shell.
  users.users.ty.shell = pkgs.fish;
  users.users.root.shell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];

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
      configurationLimit = 30;
    };
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
      options = "--delete-older-than 7d";
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

  security.polkit.enable = true;

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
    packages = with pkgs; [
    ];
  };

  # Networking PKGS + parameters.
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Force electron apps to wayland and turn off hardware cursors.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Install PKGS with system parameters.
  programs.regreet.enable = true;
  programs.tmux.enable = true;
  programs.fish.enable = true;
  programs.yazi.enable = true;
  programs.virt-manager.enable = true;
  programs.zoxide.enable = true;
  programs.atuin.enable = true;
  programs.starship.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
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
      hyprpolkitagent
      pinentry-gnome3
      nh
      nix-output-monitor
      nvd
      waybar
      mako
      pavucontrol
      rofi-rbw-wayland
      wl-clipboard
      cliphist
      wtype
      wget
      wofi
      ghostty
      rbw
      mpv
      imv
      hyprshot
      hyprpaper
      hyprpicker
      vesktop
      qalculate-gtk
      btop
      fastfetch
      jq
    ])
    ++ [
      inputs.zen-browser.packages.${pkgs.system}.default
    ];

  hardware.keyboard.qmk.enable = true;

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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  # Display Manager.
  services.greetd.enable = true;

  # Sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
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

  # Port for SSH opened.
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Udev rules for keyboard/mouse permissions.
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "keychron-udev-rules";
      destination = "/etc/udev/rules.d/50-keychron.rules";
      text = ''
                # KEYCHRON KEYBOARDS & RECEIVERS (Factory ZMK, VIA, or QMK Modes)
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
                SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

                # KEYCHRON KEYBOARDS & RECEIVERS (Factory ZMK, VIA, or QMK Modes)
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d028", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
                SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d028", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

        	# VIAL COMPATIBILITY LAYER
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

                # UNIVERSAL MOUSE / POINTER INPUTS
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="*input*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

                # Catch-all for the specific GigaDevice/Keychron DFU chip variant
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", MODE="0660", GROUP="users", TAG+="uaccess"
      '';
    })
  ];

  services.gnome.gnome-keyring.enable = true;
  services.power-profiles-daemon.enable = true;

  systemd.user.services.waybar = {
    unitConfig = {
      After = [ "graphical-session.target" ];
      Requires = [ "dbus.socket" ];
    };
    serviceConfig = {
      ExecStartPre = "${pkgs.glib}/bin/gdbus wait --system net.hadess.PowerProfiles";
    };
  };

  systemd.user.services.rbw-autounlock = {
    description = "Securely unlock Bitwarden Vault on Hyprland Startup";
    wantedBy = [ "graphical-session.target" ];
    unitConfig = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.rbw}/bin/rbw unlock";
      RemainAfterExit = false;
    };
  };

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
