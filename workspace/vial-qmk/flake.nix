{
  description = "Vial-QMK development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "vial-qmk-env";
        
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
          echo "⚡ Vial-QMK Development Environment Loaded ⚡"
          # Ensures QMK knows where to look if it needs internal dependencies
          export QMK_HOME="$PWD/vial-qmk" 
        '';
      };
    };
}
