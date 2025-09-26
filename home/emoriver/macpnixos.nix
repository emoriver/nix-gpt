{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/system/fonts.nix
    ../../modules/nixos/system/locale.nix
    ../../modules/nixos/system/nix.nix
    ../../modules/nixos/system/env.nix
    ../../modules/home/apps/neovim.nix
    ../../modules/home/apps/firefox.nix
  ];

  networking.hostName = "host__1__";

  time.timeZone = "Europe/Rome";

  users.users.emoriver = {
    isNormalUser = true;
    home = "/home/emoriver";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  services.openssh.enable = true;
  system.stateVersion = "25.05";
}
