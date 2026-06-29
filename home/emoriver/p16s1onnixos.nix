{
  pkgs,
  pkgsUnstable,
  ...
}:

{
  # Import delle app Home-Manager (moduli)
  imports = [
    ../../modules/home/apps/zsh.nix
    ../../modules/home/apps/git.nix
    ../../modules/home/apps/firefox.nix
    ../../modules/home/apps/vscodium.nix
    ../../modules/home/apps/kiro.nix
    ../../modules/home/apps/ghostty.nix

    ../../modules/home/de/niri.nix
    ../../modules/home/de/noctalia.nix
  ];

  # Identità + versione HM
  home.username = "emoriver";
  home.homeDirectory = "/home/emoriver";
  home.stateVersion = "25.11";

  # Pacchetti utente
  home.packages =
    (with pkgs; [
      bat
      eza
      fd
      ripgrep
      fzf
      jq
      yq-go

      filezilla

      imagemagick
      yazi

      nixd

      thunar
      tumbler
      brightnessctl
    ])
    ++ (with pkgsUnstable; [
      #kiro  # installato tramite modules/home/apps/kiro.nix
    ]);

  # Esempio di file utente gestito da HM
  #home.file.".config/myapp/config.toml".text = ''
  #  # Config specifica per host__1__
  #  enabled = true
  #'';

  systemd.user.startServices = "sd-switch";
}
