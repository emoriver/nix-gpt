{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # audio
    ../../modules/nixos/system/audio
    ../../modules/nixos/system/audio/dragonfly.nix
    ../../modules/nixos/system/audio/mpd.nix

    ../../modules/nixos/services/streaming.nix
    
    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    ../../modules/nixos/system/persistence/nixerrypi.nix
  ];

  # ── Identità macchina ──────────────────────────────────────────────────────
  networking.hostName = "nixerrypie";
  time.timeZone       = "Europe/Rome";
  i18n.defaultLocale  = "it_IT.UTF-8";

  # ── Raspberry Pi 4B ───────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  # ── Rete ───────────────────────────────────────────────────────────────────
  # Ethernet via DHCP (consigliato per stabilità audio).
  # WiFi configurabile opzionalmente.
  # ───────────────────────────────────────────────────────────────────────────
  networking = {
    # Ethernet — DHCP automatico
    interfaces.eth0.useDHCP = true;

    # ── WiFi (opzionale) ────────────────────────────────────────────────────
    # Decommentare se si usa WiFi invece di Ethernet.
    # Le credenziali sono in /persist/wpa_supplicant.conf
    #
    # wireless = {
    #   enable = true;
    #   environmentFile = "/persist/wifi-credentials";
    #   networks = {
    #     "NomeRete".psk = "@PSK_NOMRETE@";  # variabile dal file
    #   };
    # };

    # Risoluzione nome locale (rpi-player.local)
    firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 ];   # SSH (MPD e myMPD aperti nel modulo mpd.nix)
    };
  };

  # mDNS — permette di raggiungere il Pi come rpi-player.local
  services.avahi = {
    enable   = true;
    nssmdns4 = true;
    publish = {
      enable      = true;
      addresses   = true;
      workstation = true;
    };
  };

  # Aspetta che la rete sia operativa prima dei mount _netdev
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.network.wait-online.enable = true;

  # ── Pacchetti di sistema ───────────────────────────────────────────────────
  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    htop
    #ncmpc       # client MPD da terminale
    #mpc         # controllo MPD da script
    ffmpeg      # decoder audio aggiuntivi
    yt-dlp      # resolver stream SoundCloud

    git 
    curl 
    wget 
    #btop 
    ripgrep 
    fd 
    unzip 
    zip 
    gnupg 
    tmux
    yazi
  ];

  # ── SSH ────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      AllowUsers = [ "emoriver" ];
    };
  };

  # ── Nix ────────────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org/"
      # Aggiungi altri se li usi (es. Cachix)
    ];
    # trusted-public-keys = [ ... ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";
}
