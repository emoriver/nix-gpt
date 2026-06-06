{ config, lib, pkgs, pkgsUnstable,... }:

{
  # Import delle app Home-Manager (moduli)
  imports = [
    ../../modules/home/apps/zsh.nix
    ../../modules/home/apps/git.nix
    ../../modules/home/apps/firefox.nix
    #../../modules/home/apps/vscodium.nix
    ../../modules/home/apps/kiro.nix

    #../../modules/home/apps/rclone/rclone.nix
    #../../modules/home/apps/rclone/rclone-sync.nix
    #../../modules/home/apps/rclone/rclone-mount.nix

    ../../modules/home/de/noctalia.nix
    ../../modules/home/de/niri.nix
  ];
  
  # Identità + versione HM
  home.username = "emoriver";
  home.homeDirectory = "/home/emoriver";
  home.stateVersion = "25.11";

  /*
  # rclone
  apps.rclone.enable = true;
  apps.rclone.withExampleOneDrive = true; 


  apps.rcloneMount = {
    enable = true;
    remoteName = "onedrive_personale";    # nome del remote configurato
    mountPoint = "/home/emoriver/OneDrive";   # cartella locale
    extraOptions = [ "--vfs-cache-mode" "writes" ];   # opzioni rclone mount
  };

  apps.rcloneSync = {
    enable = true;
    remoteName = "onedrive_personale";    # nome del remote configurato
    targetDir = "/home/emoriver/OneDriveSync";    # cartella locale
    frequency = "hourly";   # oppure "daily", "weekly", ecc.
  };
  */

  # Pacchetti utente
  home.packages =
    (with pkgs; [
      bat eza fd ripgrep fzf jq yq-go

      #exiftool
      #obsidian
      #gimp
      #arduino-ide

      filezilla

      imagemagick
      yazi

    ])
    ++(with pkgsUnstable; [
      kiro
  ]);


  # Esempio di file utente gestito da HM
  #home.file.".config/myapp/config.toml".text = ''
  #  # Config specifica per host__1__
  #  enabled = true
  #'';

  systemd.user.startServices = "sd-switch";
}
