{ config, pkgs, ... }:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    # pacchetti di sistema
    ../../modules/nixos/system/audio
    ../../modules/nixos/de/plasma6.nix
    ../../modules/nixos/de/niri.nix

    # utenti
     ../../modules/nixos/users/emoriver.nix

    # servizi
    ../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/docker.nix
    #../../modules/nixos/services/vpn.nix
  ];
  

  # ----- boot e hardware/configurazioni di base -----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;



  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Essenziale per app a 32 bit e Wine/Steam
    extraPackages = with pkgs; [


    ];
  };

  #services.xserver.videoDrivers = [ "amdgpu" ];



  # ----- rete e localizzazione -----
  networking = {
    hostName = "p16s1onnixos";
    networkmanager.enable = true;
    wireless.enable = false; # Don't conflict with NetworkManager
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

  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.overrideAttrs (old: {
        doCheck = false; # Salta i test unitari di Rust che falliscono sul Trashcan
      });
    })
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
    
    substituters = [
      "https://cache.nixos.org/"
      "https://niri.cachix.org"
      "https://noctalia.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfry9qGridkHN5sXFcBrpVOaBi8JQ="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
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
      AllowUsers = [ "emoriver" ];
    };
  };

  services.postgresql = {
    enable = true;
  };

  enableDocker = true;

  # Stampa/Bluetooth
  #services.printing.enable = true;   #CUPS
  hardware.bluetooth.enable = true;


  # ----- programmi e pacchetti di sistema host-level  -----
  programs = {
    zsh.enable = true;
    #git.enable = true;
    ssh.startAgent = true;
  };

  services.gnome.gcr-ssh-agent.enable = false;

  environment.systemPackages = with pkgs; [
    #vim
    curl 
    wget 
    htop 
    btop 
    unzip 
    zip 
    gnupg 
    tmux
    parted
    nh

    lm_sensors      # For temperature/fan monitoring
    mission-center  # Modern system monitor with thermal info
  ];

  environment.etc."ipsec.d/00-global.conf".text = ''
    config setup
      ikev1-policy=accept
  '';

  # ----- btrfs -----
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  system.stateVersion = "25.11";
}
