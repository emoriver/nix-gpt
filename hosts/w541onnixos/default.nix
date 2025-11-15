{ config, pkgs, ... }:

{
  imports = [
    ../common
    ../../modules/nixos/system/boot/grub.nix
    ../../modules/nixos/services/ssh.nix
    ../../modules/nixos/apps/firefox.nix
    ../../hosts/users/emoriver.nix
  ];

  networking.hostName = "w541onnixos";
}