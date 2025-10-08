{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.enableDocker {
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [ docker ];
  };

  options.enableDocker = lib.mkEnableOption "Enable Docker";
}