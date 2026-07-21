{
  description = "AstroNvim Replication Package using NVF";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nvf,
      ...
    }:
    let
      # Supported architectures for your PC and your phone
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Generates configuration dynamically for each architecture
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f rec {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
            customNeovim = nvf.lib.neovimConfiguration {
              inherit pkgs;
              modules = [
                {
                  config.vim = {
                    viAlias = false;
                    vimAlias = false;

                    # Global Options & Themes
                    options = {
                      shiftwidth = 2;
                      tabstop = 2;
                      expandtab = true;
                      termguicolors = true;
                      number = true;
                      relativenumber = true;
                      mouse = "a";
                    };

                    theme = {
                      enable = true;
                      name = "gruvbox";
                      style = "dark";
                      transparent = false;
                    };

                    statusline.lualine = {
                      enable = true;
                    };

                    visuals = {
                      nvim-web-devicons.enable = true;
                      nvim-scrollbar.enable = true;
                      cinnamon-nvim.enable = true;
                      indent-blankline.enable = true;
                      nvim-cursorline.enable = true;
                    };

                    dashboard.alpha.enable = true;
                    filetree.neo-tree.enable = true;
                    telescope.enable = true;

                    # Core AstroNvim Utilities
                    git = {
                      enable = true;
                      gitsigns.enable = true;
                    };

                    autopairs.nvim-autopairs.enable = true;
                    utility.motion.hop.enable = true;
                    binds.whichKey.enable = true;

                    terminal.toggleterm = {
                      enable = true;
                      setupOpts.direction = "float";
                    };

                    # FIXED: Changed from nvimBufferLine to nvimBufferline
                    tabline.nvimBufferline.enable = true;
                    autocomplete.blink-cmp.enable = true;
                    snippets.luasnip.enable = true;

                    keymaps = [
                      {
                        key = "<leader>e";
                        action = ":Neotree toggle<CR>";
                        mode = "n";
                        desc = "Toggle Explorer";
                      }
                      {
                        key = "<leader>ff";
                        action = ":Telescope find_files<CR>";
                        mode = "n";
                        desc = "Find Files";
                      }
                      {
                        key = "<leader>fw";
                        action = ":Telescope live_grep<CR>";
                        mode = "n";
                        desc = "Find Words";
                      }
                      {
                        key = "<leader>tf";
                        action = ":ToggleTerm<CR>";
                        mode = "n";
                        desc = "Toggle Floating Terminal";
                      }
                      {
                        key = "L";
                        action = ":BufferLineCycleNext<CR>";
                        mode = "n";
                        desc = "Next Buffer";
                      }
                      {
                        key = "H";
                        action = ":BufferLineCyclePrev<CR>";
                        mode = "n";
                        desc = "Previous Buffer";
                      }
                      {
                        key = "<leader>c";
                        action = ":bdelete<CR>";
                        mode = "n";
                        desc = "Close Buffer";
                      }
                    ];

                    lsp = {
                      enable = true;
                      formatOnSave = true;
                    };

                    # Languages and Automatic LSPs
                    languages = {
                      enableTreesitter = true;
                      enableFormat = true;
                      enableExtraDiagnostics = true;

                      nix = {
                        enable = true;
                        lsp.servers = [ "nixd" ];
                        format.type = [ "nixfmt" ];
                      };

                      lua = {
                        lsp.servers = [ "lua-language-server" ];
                        format.type = [ "stylua" ];
                      };

                      python = {
                        lsp.servers = [
                          "pyright"
                          "basedpyright"
                          "python-lsp-server"
                        ];
                        format.type = [ "black" ];
                      };

                      yaml = {
                        enable = true;
                        format.type = [ "prettier" ];
                      };

                      fish.enable = true;
                      bash.enable = true;
                      json.enable = true;
                      toml.enable = true;
                      css.enable = true;
                      xml.enable = true;
                      markdown.enable = true;
                      html.enable = true;
                    };

                    diagnostics.presets = {
                      statix.enable = true;
                      deadnix.enable = true;
                    };

                    notes = {
                      neorg = {
                        enable = true;
                        setupOpts = {
                          workspaces = [
                            {
                              name = "notes";
                              path = "~/Documents/norg/notes";
                            }
                          ];
                        };
                      };
                    };
                  };
                }
              ];
            };
          }
        );
    in
    {
      # Exposes the packages for both system environments
      packages = forAllSystems (
        {
          system,
          pkgs,
          customNeovim,
        }:
        {
          default = pkgs.symlinkJoin {
            name = "nvf-wrapped";
            paths = [ customNeovim.neovim ];
            postBuild = ''
              ln -s $out/bin/nvim $out/bin/nvf
            '';
          };
        }
      );
    };
}
