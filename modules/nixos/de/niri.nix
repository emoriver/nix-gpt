{ pkgs, ... }:

{
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
    foot        # terminale
    grim        # screenshot
    slurp       # selezione area
    wl-clipboard
  ];
}