{ config, pkgs, ... }:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    # pacchetti di sistema
    ../../modules/nixos/system/audio.nix
    ../../modules/nixos/de/plasma6.nix

    # utenti - !! -
     ../../modules/nixos/users/emoriver.nix

    # servizi
    #../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/vpn.nix
  ];
  

  # ----- boot e hardware/configurazioni di base -----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Blacklist conflicting open-source drivers
  boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" "brcmsmac" "brcmfmac" ];

  boot.kernelParams = [ 
      "radeon.si_support=0" 
      "amdgpu.si_support=1" 
      "radeon.cik_support=0" # Per sicurezza, disabilita anche Sea Islands
      "amdgpu.cik_support=1" 
    ];

  boot.kernelModules = [ 
    "applesmc"      # Apple System Management Controller
    "coretemp"      # CPU temperature sensors
    "wl"            # Broadcom BCM4360 requires the proprietary wl driver
  ];

  # Config for Radeon D dual card
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Essenziale per app a 32 bit e Wine/Steam
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl

      vulkan-loader
      vulkan-validation-layers

      #vaapiIntel         # Anche se hai AMD, alcuni pacchetti dipendono da questi base
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  # Fan module (!!)
  services.mbpfan.enable = true;


  # WiFi Configuration for BCM4360
  hardware.enableRedistributableFirmware = true;

  # Broadcom BCM4360
  boot.extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];

  # You might need this if you get insecure package warnings
  nixpkgs.config.permittedInsecurePackages = [
    #"broadcom-sta-6.30.223.271-59-6.12.62"
    "broadcom-sta-6.30.223.271-59-6.12.63"
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
      AllowUsers = [ "emoriver" ];
    };
  };

  #services.postgresql = {
  #  enable = true;
  #};

  enableDocker = true;

  # Stampa/Bluetooth (abilita se ti servono su questo host)
  services.printing.enable = true;   #CUPS
  # hardware.bluetooth.enable = true;


  # ----- programmi e pacchetti di sistema host-level  -----
  programs = {
    zsh.enable = true;
    #git.enable = true;
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

  system.stateVersion = "25.05";
}
