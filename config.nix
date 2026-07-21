# Help is in configuration.nix(5) man page, https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
  lib,
  inputs,
  self,
  ...
}:
{
  imports = [
    ./modules/hardware/hardware.nix
    ./modules/hardware/amd.nix
    ./modules/hardware/nvidia.nix
  ];

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
      options = "--delete-older-than 5d";
    };
  };

  # User account.
  security = {
    polkit.enable = true;
    doas = {
      enable = true;
      extraRules = [
        {
          users = [ "ty" ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };
    sudo = {
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
  };

  # User parameters.
  users = {
    mutableUsers = true;
    users.root.shell = pkgs.fish;
    users.ty = {
      shell = pkgs.fish;
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
      packages = [
        #
      ];
    };
  };

  # Networking PKGS + parameters.
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "dnsmasq";
    };
    firewall = {
      allowedTCPPorts = [ 22 ];
      trustedInterfaces = [ "tailscale0" ];
    };
    wireless.enable = false;
  };

  # Install PKGS with system parameters.
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    git = {
      enable = true;
      config = {
        user = {
          name = "Ty";
          email = "ogoxy.yt@gmail.com";
          signingkey = "~/.ssh/id_ed25519.pub";
        };
        gpg.format = "ssh";
        commit.gpgsign = true;
      };
    };
    ssh = {
      extraConfig = ''
        Host Nix-On-Droid
            HostName 100.71.190.30
            Port 8022
            User nix-on-droid
            StrictHostKeyChecking no
            RequestTTY yes
            UserKnownHostsFile /dev/null

        Host NixOS
            HostName 100.99.131.97
            Port 22
            User ty
            StrictHostKeyChecking no
            RequestTTY yes
            UserKnownHostsFile /dev/null
      '';
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
    regreet.enable = true;
    fish.enable = true;
    zoxide.enable = true;
    gamemode.enable = true;
    steam.enable = true;
    virt-manager.enable = true;
    nano.enable = false;
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      font-awesome
      comic-mono
      fantasque-sans-mono
      cozette
      monaspace
      inter
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
          "Font Awesome 6 Free"
          "Font Awesome 6 Brands"
          "FiraCode Nerd Font"
          "Comic Mono"
          "Fantasque Sans Mono"
          "Cozette"
          "Monaspace Neon"
          "Inter"
        ];
        sansSerif = [
          "Inter"
          "Font Awesome 6 Free"
          "Font Awesome 6 Brands"
          "JetBrainsMono Nerd Font"
          "FiraCode Nerd Font"
          "Comic Mono"
          "Fantasque Sans Mono"
          "Cozette"
          "Monaspace Neon"
        ];
        serif = [
          "Comic Mono"
          "Font Awesome 6 Free"
          "Font Awesome 6 Brands"
          "JetBrainsMono Nerd Font"
          "FiraCode Nerd Font"
          "Inter"
          "Fantasque Sans Mono"
          "Cozette"
          "Monaspace Neon"
        ];
      };
      localConf = ''

      '';
    };
  };

  # Install system PKGS.
  environment = {
    shells = with pkgs; [ fish ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      ANTHROPIC_BASE_URL = "http://127.0.0.1:11434/v1";
      ANTHROPIC_API_KEY = "local";
      ANTHROPIC_DEFAULT_SONNET_MODEL = "qwen-14b";
      CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
      EDITOR = "nvf";
      VISUAL = "nvf";
    };
    systemPackages =
      with pkgs;
      [
        hyprpolkitagent
        pinentry-gnome3
        waybar
        mako
        wofi
        ghostty
        hyprpaper
        bitwarden-desktop
        vesktop
        pavucontrol
        qalculate-gtk
        #CLI-Tools.
        nix-output-monitor
        nvd
        nh
        fh
        rbw
        rofi-rbw-wayland
        mpv
        imv
        hyprshot
        hyprpicker
        btop
        fastfetch
        tealdeer
        wl-clipboard
        cliphist
        wtype
        curl
        w3m
        wget
        wget2
        fzf
        ripgrep
        herdr
        llama-cpp
        fd
        bun
        devenv
        starship
        atuin
        # Formatters.
        nixfmt
        jq
      ]
      ++ [
        inputs.zen-browser.packages.${pkgs.system}.default
        inputs.nvf.packages.${pkgs.system}.default
        inputs.llm-agents.packages.${pkgs.system}.default
      ];
    etc = {
      #
    };
  };

  nixpkgs.config.cudaSupport = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  hardware = {
    i2c.enable = true;
    keyboard.qmk.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
  };

  # Display Manager.
  services = {
    gnome.gnome-keyring.enable = true;
    power-profiles-daemon.enable = true;
    hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      motherboard = "amd";
    };
    kmscon.enable = true;
    greetd.enable = true;
    tailscale.enable = true;
    logind.settings = {
      Login = {
        IdleAction = "ignore";
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    zram-generator = {
      enable = true;
      settings = {
        zram0 = {
          compression-algorithm = "lz4";
          zram-size = 16384;
        };
      };
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
    llama-cpp = {
      enable = true;
      package =
        (pkgs.llama-cpp.override {
          cudaSupport = true;
        }).overrideAttrs
          (oldAttrs: {
            # This is how you correctly pass extra flags to the build system
            cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
              "-DCMAKE_CUDA_ARCHITECTURES=61"
            ];
          });
      settings = {
        hf-repo = "Qwen/Qwen2.5-Coder-14B-Instruct-GGUF";
        hf-file = "qwen2.5-coder-14b-instruct-q5_k_m.gguf";
        port = 8012;
        jinja = true;
        ctx-size = 4096;
        n-gpu-layers = 20;
      };
    };
    resolved.enable = false;
    libinput.enable = false;
    printing.enable = false;
  };

  powerManagement.cpuFreqGovernor = "performance";

  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
    services = {
      ollama.wantedBy = pkgs.lib.mkForce [ ];
      llama-cpp.wantedBy = pkgs.lib.mkForce [ ];
    };
    user.services = {
      waybar = {
        unitConfig = {
          After = [ "graphical-session.target" ];
          Requires = [ "dbus.socket" ];
        };
        serviceConfig = {
          ExecStartPre = "${pkgs.glib}/bin/gdbus wait --system net.hadess.PowerProfiles";
        };
      };
      rbw-autounlock = {
        description = "Securely unlock Bitwarden Vault on Hyprland Startup";
        wantedBy = [ "graphical-session.target" ];
        unitConfig = {
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        serviceConfig = {
          Type = "oneshot";
          Environment = [
            "WAYLAND_DISPLAY=wayland-0"
            "DISPLAY=:0"
          ];
          ExecStart = "${pkgs.rbw}/bin/rbw unlock";
          RemainAfterExit = false;
        };
      };
    };
  };

  # NixOS VM sandbox.
  virtualisation = {
    vmVariant = {
      users.users = {
        ty.password = "test";
        root.password = "test";
      };
      virtualisation = {
        memorySize = 8192;
        cores = 8;
        qemu.options = [ "-device virtio-vga-gl -display gtk,gl=on" ];
      };
    };
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  # Time zone.
  time.timeZone = "America/New_York";

  # Origin NixOS install version, NEVER CHANGE.
  system = {
    stateVersion = "26.05";
    configurationRevision = lib.mkIf (self ? rev) self.rev;
    systemBuilderCommands = ''
      ln -s ${self} $out/src
    '';
  };
}
