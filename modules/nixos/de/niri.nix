{ inputs, pkgs, ... }:

{
  imports = [ inputs.niri-flake.nixosModules.niri ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;  # usa pkgs.niri → l'overlay doCheck=false si applica
  };
  
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