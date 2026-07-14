{
  description = "System and Home Manager configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nvf.url = "path:./flakes/NVF";
    llm-agents.url = "path:./flakes/LLM-Agents";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  } @ inputs: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs self;};
      modules = [
        ./config.nix
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.permittedInsecurePackages = [
            "electron-39.8.10"
          ];
          nixpkgs.overlays = [
            (
              final: prev: let
                stable = import nixpkgs-stable {
                  inherit (prev) system;
                  config = prev.config;
                };
              in {
                cantarell-fonts = stable.cantarell-fonts;
              }
            )
          ];
        }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.root = import ./modules/home/root-home.nix;
            users.ty = import ./modules/home/ty-home.nix;
            extraSpecialArgs = {inherit inputs self;};
          };
        }
      ];
    };
  };
}
