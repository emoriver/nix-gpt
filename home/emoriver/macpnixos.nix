{ config, lib, pkgs, ... }:

{
  # Import delle app Home-Manager (moduli)
  imports = [
    ../../modules/home/apps
  ];

  # Identità + versione HM
  home.username = "user1";
  home.homeDirectory = "/home/user1";
  home.stateVersion = "24.05";

  # Abilita le app che vuoi su questo host
  apps.git = {
    enable = true;
    userName = "Andrea Riva";
    userEmail = "emoriver@live.it";
  };

  apps = {
    zsh.enable = true;
    git.enable = true;
    neovim.enable = true;
    ssh.enable = true;
    direnv.enable = true;
    zoxide.enable = true;
    starship.enable = true;
    kdeconnect.enable = true;
    alacritty.enable = false; # metti true se lo usi
  };

  # Pacchetti utente (se vuoi aggiunte "sciolte")
  home.packages = with pkgs; [
    bat eza fd ripgrep fzf jq yq-go
  ];

  # Esempio di file utente gestito da HM
  home.file.".config/myapp/config.toml".text = ''
    # Config specifica per host__1__
    enabled = true
  '';

  systemd.user.startServices = "sd-switch";
}