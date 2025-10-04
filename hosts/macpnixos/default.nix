{ config, pkgs, ... }:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/system/audio.nix
    ../../modules/nixos/de/plasma6.nix
  ];
  

  # ----- boot e hardware/configurazioni di base -----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Blacklist conflicting open-source drivers
  boot.blacklistedKernelModules = [ "amdgpu" "b43" "bcma" "ssb" "brcmsmac" "brcmfmac" ];
  boot.initrd.kernelModules = [ "radeon" ];

  boot.kernelParams = [ 
      #"radeon.dpm=0" 
      "radeon.si_support=0" "amdgpu.si_support=1"
    ];
    
  boot.kernelModules = [ 
    "applesmc"      # Apple System Management Controller
    "coretemp"      # CPU temperature sensors
    "wl"            # Broadcom BCM4360 requires the proprietary wl driver
  ];

  # WiFi Configuration for BCM4360
  #nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  # Broadcom BCM4360
  boot.extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];

  # You might need this if you get insecure package warnings
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271"
  ];


  # ----- rete e localizzazione -----
  networking = {
    hostName = "macpnixos";
    networkmanager.enable = true;
    wireless.enable = false; # Don't conflict with NetworkManager
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ];
    };
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "it_IT.UTF-8";
  console.keyMap = "it
  ";

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
    options = "--delete-older-than 30d";
  };


  # ----- servizi di base -----
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Stampa/Bluetooth (abilita se ti servono su questo host)
  printing.enable = true;   #CUPS
  # hardware.bluetooth.enable = true;


  # ----- programmi e pacchetti di sistema host-level  -----
  programs = {
    zsh.enable = true;
    git.enable = true;
    ssh.startAgent = true;
  };

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

    lm_sensors      # For temperature/fan monitoring
    mission-center  # Modern system monitor with thermal info
  ];


  # ----- utenti e home-manager -----
  programs.home-manager.enable = true;

  home.username = "emoriver";
  home.homeDirectory = "/home/emoriver";

  # -----  
  system.stateVersion = "25.05";
}