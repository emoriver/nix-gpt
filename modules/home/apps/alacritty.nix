{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.apps.alacritty;
in
{
  options.apps.alacritty.enable = mkEnableOption "Installa e configura Alacritty";

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.95;
        font.size = 11.0;
      };
    };
  };
}