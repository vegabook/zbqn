{
  description = "bqn development environment with experimental zig";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    # Optional but recommended: reduce eval time & avoid duplicate nixpkgs
    # zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Flake outputs
  outputs = { self, nixpkgs, zig-overlay }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux"    # 64-bit Intel/AMD Linux
        "aarch64-linux"   # 64-bit ARM Linux
        "x86_64-darwin"   # 64-bit Intel macOS
        "aarch64-darwin"  # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          # The Nix packages provided in the environment
          packages = with pkgs; [
            cbqn
            zig
            libffi
            cmake
          ];

          shellHook = ''
            if [ -z "$NIX_SHELL_NESTED" ]; then
              export NIX_SHELL_NESTED=1
              alias ipy="uv run ipython --nosep"
              export PS1="🫏 \e[38;5;095m\]Z\e[38;5;094m\]BQN\e[0m $PS1"
            else
              echo "Nested nix-shell detected"
              export PS1="🫏 \e[38;5;095m\]Z\e[38;5;094m\]BQN [NESTED] \e[0m $PS1"
            fi
          '';
        };
      });
    };
}
