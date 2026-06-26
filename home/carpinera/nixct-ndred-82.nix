{ config, lib, pkgs, ... }:

{
  # Import delle app Home-Manager (moduli)
  imports = [
    ../../modules/home/apps/zsh.nix
    ../../modules/home/apps/git.nix


  ];
  
  # Identità + versione HM
  home.username = "carpinera";
  home.homeDirectory = "/home/carpinera";
  home.stateVersion = "26.05";

  # Pacchetti utente (se vuoi aggiunte "sciolte")
  home.packages = with pkgs; [
    bat eza fd ripgrep fzf jq yq-go

  ];

  # Esempio di file utente gestito da HM
  #home.file.".config/myapp/config.toml".text = ''
  #  # Config specifica per host__1__
  #  enabled = true
  #'';

  systemd.user.startServices = "sd-switch";
}
