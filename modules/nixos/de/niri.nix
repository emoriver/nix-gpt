{ inputs, pkgs, ... }:

{
  imports = [ inputs.niri-flake.nixosModules.niri ];
  programs.niri = {
    enable = true;
    package = pkgs.niri;
    #xwayland = true;
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
  #fuzzel
  grim
  slurp
  wl-clipboard
  xwayland-satellite
  gnome-keyring
  libsecret  # libreria per accedere al keyring
];

services.gnome.gnome-keyring.enable = true;
security.pam.services.niri.enableGnomeKeyring = true;
security.pam.services.login.enableGnomeKeyring = true;

  # Abilita xwayland-satellite come servizio systemd utente
  systemd.user.services.xwayland-satellite = {
    description = "Xwayland outside your Wayland compositor";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      Restart = "on-failure";
    };
  };
}