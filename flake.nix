{
  description = "System and Home Manager configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    astrovim-nvf.url = "path:./flakes/nvf";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs self; };
        modules = [
          ./config.nix
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];
            nixpkgs.overlays = [
              (
                final: prev:
                let
                  stablePkgs = import nixpkgs-stable {
                    inherit (prev) system;
                    config = prev.config;
                  };
                in
                {
                  cantarell-fonts = stablePkgs.cantarell-fonts;
                }
              )
            ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.root = import ./modules/homes/root-home.nix;
            home-manager.users.ty = import ./modules/homes/ty-home.nix;
            home-manager.extraSpecialArgs = { inherit inputs self; };
          }
        ];
      };
    };
}
