{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Import delle app Home-Manager (moduli)
  imports = [
    ../../modules/home/apps/zsh.nix
    ../../modules/home/apps/git.nix
    ../../modules/home/apps/firefox.nix
    ../../modules/home/apps/vscodium.nix
    ../../modules/home/apps/ghostty.nix

    ../../modules/home/de/niri.nix
    ../../modules/home/de/noctalia.nix

  ];

  # Identità + versione HM
  home.username = "emoriver";
  home.homeDirectory = "/home/emoriver";
  home.stateVersion = "25.11";

  # Pacchetti utente (se vuoi aggiunte "sciolte")
  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    fzf
    jq
    yq-go
    #spotify
    dbeaver-bin
    #keepassxc
    #thunderbird
    #rawtherapee
    #exiftool
    nixd
    nixfmt
    remmina
    thunar
    tumbler
    brightnessctl
    winbox
  ];

  # Esempio di file utente gestito da HM
  #home.file.".config/myapp/config.toml".text = ''
  #  # Config specifica per host__1__
  #  enabled = true
  #'';

  systemd.user.startServices = "sd-switch";
}
