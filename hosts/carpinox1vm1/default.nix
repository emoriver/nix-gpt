{ config, pkgs, ... }:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    # pacchetti di sistema
    ../../modules/nixos/system/audio
    ../../modules/nixos/de/plasma6.nix
    ../../modules/nixos/de/niri.nix

    # utenti - !! -
     ../../modules/nixos/users/carpinera.nix

    # servizi
    #../../modules/nixos/services/postgresql.nix
    #../../modules/nixos/services/docker.nix
    #../../modules/nixos/services/vpn.nix
  ];
  
  # ----- boot e hardware/configurazioni di base -----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ----- rete e localizzazione -----
  networking = {
    hostName = "carpinox1vm1";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ];
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "it_IT.UTF-8";
    };
    supportedLocales =  [
      "en_US.UTF-8/UTF-8"
      "it_IT.UTF-8/UTF-8"
    ];
  };
  #location.provider = "geoclue2";
  time.timeZone = "Europe/Rome";


  # ----- impostazioni di nix -----
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


  # ----- servizi di base -----
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  services.qemuGuest.enable = true;
  services.xserver.videoDrivers = [ "virtio" ];
  hardware.graphics.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  security.pam.services.noctalia = {};


  # ----- programmi e pacchetti di sistema host-level  -----
  programs = {
    zsh.enable = true;
    #git.enable = true;
    ssh.startAgent = true;
  };

  services.gnome.gcr-ssh-agent.enable = false;

  environment.systemPackages = with pkgs; [
    #vim
    git 
    curl 
    wget 
    htop 
    btop 
    ripgrep 
    fd 
    unzip 
    zip 
    gnupg 
    tmux
  ];

    
  # ----- btrfs -----
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  system.stateVersion = "25.11";
}
