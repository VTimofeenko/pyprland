{ localFlake, withSystem }:
{ pkgs, lib, self, config, ... }:
with lib;
let
  cfg = config.programs.pyprland;
in
{
  options = {
    programs.pyprland = {
      enable = mkEnableOption "pyprland";
      package = mkOption {
        type = types.package;
        default = localFlake.packages.${pkgs.stdenv.hostPlatform.system}.default;
        description = "pyprland package to use";
      };
      extraConfig = mkOption {
        type = types.attrs;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."hypr/pyprland.json" = {
      text = builtins.toJSON cfg.extraConfig;
    };
  };
}
