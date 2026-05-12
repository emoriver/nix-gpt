{ inputs, pkgs, ... }:

{
  imports = [ inputs.niri-flake.nixosModules.niri ];

  programs.niri.enable = true;

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    foot
    grim
    slurp
    wl-clipboard
  ];
}