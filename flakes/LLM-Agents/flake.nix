{
  description = "Ty's Standalone AI Agent Hub - Package & DevShell Targets";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
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

            buildInputs = [
              agents.claude-code
              agents.crush
              agents.goose-cli
              pkgs.llama-cpp
              pkgs.ripgrep
              pkgs.git
            ];

            shellHook = ''
              echo "========================================================"
              echo " 🤖 AI AGENT SANDBOX ACTIVATED                          "
              echo " System Context: ${pkgs.system}                         "
              echo " Available: claude-code, crush, goose                   "
              echo "========================================================"
            '';
          };
        }
      );
    };
}
