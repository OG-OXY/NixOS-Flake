{
  description = "QMK development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "QMK-ENV";
        nativeBuildInputs = with pkgs; [
          git
          gnumake
          qmk
          dfu-programmer
          dfu-util
          avrdude
          gcc-arm-embedded
        ];

        shellHook = ''
          echo "⚡ QMK Development Environment Loaded ⚡"
          export QMK_HOME="$PWD/vial-qmk" 
        '';
      };
    };
}
