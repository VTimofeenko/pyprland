{
  description = "Description for the project";

  inputs = {
    poetry2nix.url = "github:nix-community/poetry2nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake
      { inherit inputs; }
      (
        { withSystem, flake-parts-lib, ... }:
        let
          inherit (flake-parts-lib) importApply;
        in
        {
          imports = [
            inputs.flake-parts.flakeModules.easyOverlay
            inputs.devshell.flakeModule
          ];
          systems = [ "x86_64-linux" "aarch64-linux" ];
          perSystem = { config, self', inputs', pkgs, system, ... }:
            let
              inherit (inputs.poetry2nix.legacyPackages.${system}) mkPoetryApplication;
              inherit (inputs.poetry2nix.packages.${system}) poetry;
            in
            {
              # Per-system attributes can be defined here. The self' and inputs'
              # module parameters provide easy access to attributes of the same
              # system.
              #
              overlayAttrs = {
                inherit (config.packages) pyprland;
              };
              packages = rec {
                pyprland = mkPoetryApplication { projectDir = ./.; };
                default = pyprland;
              };
              formatter = pkgs.nixpkgs-fmt;
              devshells.default = {
                env = [ ];
                commands = [ ];
                packages = [
                  poetry
                  pkgs.pre-commit
                ];
              };
            };
          flake = {
            # homeManagerModules.default = import ./nix/home-module.nix;
            homeManagerModules.default = importApply ./nix/home-module.nix { localFlake = self; inherit withSystem; };
          };
        }
      );
}
