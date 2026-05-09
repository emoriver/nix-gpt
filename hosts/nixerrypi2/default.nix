{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    #questa maledetta piccola riga causa la compilazione del kernel localmente...!!
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4

    # audio
    ../../modules/nixos/system/audio
    ../../modules/nixos/system/audio/dragonfly.nix
    ../../modules/nixos/system/audio/mpd.nix

    ../../modules/nixos/services/streaming.nix
    
    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    #../../modules/nixos/system/persistence/nixerrypi.nix
  ];

  # ── Identità macchina ──────────────────────────────────────────────────────
  networking.hostName = "nixerrypi2";
  time.timeZone       = "Europe/Rome";
  i18n.defaultLocale  = "it_IT.UTF-8";

  # ── Raspberry Pi 4B ───────────────────────────────────────────────────────
  #hardware.enableRedistributableFirmware = true;
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

    #── WiFi (opzionale) ────────────────────────────────────────────────────
    wireless = {
      enable = true;
      networks = {
        "aegm3" = {
          psk = "password_1";
          priority = 10;
        };
        "aegm1" = {
          psk = "password_2";
          priority = 5;
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22     # SSH
        6600   # MPD
        80     # myMPD web UI
      ];
      allowedUDPPorts = [ 
        5353   # Utile per mDNS/Avahi (per trovare il Pi come nixerrypi2.local)
        1900   # UPnP/SSDP
      ];
      allowedTCPPortRanges = [
        { from = 57621; to = 57621; }
        { from = 49152; to = 65535; }   # porte dinamiche
      ];
      allowedUDPPortRanges = [
       { from = 57621; to = 57621; }
       { from = 49152; to = 65535; }
      ];
      extraCommands   = ''
        iptables -A INPUT -p udp -d 224.0.0.251 --dport 5353 -j ACCEPT
        iptables -A INPUT -p udp -s 224.0.0.251 --sport 5353 -j ACCEPT
      '';
    };
  };

  # ── Pacchetti di sistema ───────────────────────────────────────────────────
  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    htop
    #btop 
    git 
    curl 
    wget 
    ripgrep 
    fd 
    unzip 
    zip 
    gnupg 
    tmux
    yazi

    ffmpeg      # decoder audio aggiuntivi
    yt-dlp      # resolver stream SoundCloud
  ];

  # ── SSH ────────────────────────────────────────────────────────────────────
  services = {
    # SSH: Per l'accesso remoto
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
        AllowUsers = [ "emoriver" ];
      };
    };

    # mDNS — permette di raggiungere il Pi come rpi-player.local
    avahi = {
      enable   = true;
      nssmdns4 = true;
      publish = {
        enable      = true;
        addresses   = true;
        workstation = true;
      };
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
