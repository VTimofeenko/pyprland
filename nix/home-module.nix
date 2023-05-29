{ localFlake, withSystem }:
{ pkgs, lib, self, config, ... }:
with lib;
let
  cfg = config.programs.pyprland;
  serviceCfg = config.services.pyprland;
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
    services.pyprland = {
      enable = mkEnableOption "" // {
        description = ''
          Whether to enable the pyprland systemd service.
          This module is complementary to <code>programs.pyprland</code> which handles the
          configuration (profiles).
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable
      {
        home.packages = [ cfg.package ];
        xdg.configFile."hypr/pyprland.json" = {
          text = builtins.toJSON cfg.extraConfig;
        };
      })
    (mkIf serviceCfg.enable
      {
        systemd.user.services.pyprland = {
          Unit = {
            Description = "pyprland service";
            BindsTo = [ "hyprland-session.target" ];
          };
          Service = {
            ExecStart = "${lib.getExe cfg.package}";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      })
  ];
}
