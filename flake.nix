{
  description = "System and Home Manager configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        specialArgs = { inherit inputs self; };
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.root = import ./root-home.nix;
            home-manager.users.ty = import ./ty-home.nix;
            home-manager.extraSpecialArgs = { inherit inputs self; };
          }
        ];
      };
    };
}
