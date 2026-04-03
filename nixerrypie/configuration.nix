{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/filesystem.nix
    ./modules/audio.nix
    ./modules/mpd.nix
    ./modules/streaming.nix
    ./modules/network.nix
    ./modules/persist.nix
  ];

  # ── Identità macchina ──────────────────────────────────────────────────────
  networking.hostName = "rpi-player";
  time.timeZone       = "Europe/Rome";
  i18n.defaultLocale  = "it_IT.UTF-8";

  # ── Raspberry Pi 4B ───────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
  boot.loader = {
    grub.enable       = false;
    generic-extlinux-compatible.enable = true;
  };

  # ── Utente principale ──────────────────────────────────────────────────────
  # La password viene hashata con: mkpasswd -m sha-512
  users.users.player = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "audio" "video" ];
    # Inserisci qui il tuo hash password
    hashedPassword = "$6$CAMBIA$questo_hash_con_mkpasswd";
    # Oppure usa una chiave SSH (consigliato)
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAA... tuachiave"
    ];
  };

  # ── Pacchetti di sistema ───────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    htop
    ncmpc       # client MPD da terminale
    mpc-cli     # controllo MPD da script
    ffmpeg      # decoder audio aggiuntivi
    yt-dlp      # resolver stream SoundCloud
  ];

  # ── SSH ────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;  # solo chiavi
      PermitRootLogin        = "no";
    };
  };

  # ── Nix ────────────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-flakes" "nix-command" ];
    auto-optimise-store   = true;
  };
  # Garbage collection automatica (libera spazio sulla SD)
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 14d";
  };

  system.stateVersion = "24.11";
}
