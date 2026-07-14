{
  description = "Ty's Standalone AI Agent Hub - Package & DevShell Targets";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      llm-agents,
      ...
    }:
    let
      # Define architectures so both PC and Android are supported natively
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true; # Required for proprietary agent engines
            }
          )
        );
    in
    {
      # TARGET 1: Standalone Package Output (For your main PC System Packages)
      packages = forEachSystem (
        pkgs:
        let
          agents = llm-agents.packages.${pkgs.system};
        in
        {
          default = pkgs.symlinkJoin {
            name = "ai-agents-bundle";
            paths = [
              agents.claude-code
              agents.crush
              agents.goose-cli
            ];
          };
        }
      );

      # TARGET 2: DevShell Output (The ultimate portable and sandboxed workspace)
      devShells = forEachSystem (
        pkgs:
        let
          agents = llm-agents.packages.${pkgs.system};
        in
        {
          default = pkgs.mkShell {
            name = "agent-sandbox";

            # Use nativeBuildInputs for devshell packages so tools are placed into $PATH properly
            nativeBuildInputs = [
              # Agents from Numtide
              agents.claude-code
              agents.crush
              agents.goose-cli

              # Native utilities from nixpkgs
              pkgs.herdr
              pkgs.devenv
              pkgs.llama-cpp
              pkgs.nodejs_22
              pkgs.ripgrep
              pkgs.gawk
              pkgs.bun
              pkgs.gh
              pkgs.fd
              pkgs.fzf
              pkgs.jq
              pkgs.git
            ];

            shellHook = ''
              echo "========================================================"
              echo " 🤖 AI AGENT SANDBOX ACTIVATED                          "
              echo " System Context: ${pkgs.system}                         "
              echo " Available: claude-code, crush, goose                   "
              echo "========================================================"
              export PATH="$PWD/node_modules/.bin:$PATH"
            '';
          };
        }
      );
    };
}
