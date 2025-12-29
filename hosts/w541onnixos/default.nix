{ config, pkgs, ... }:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    #boot
    ../../modules/nixos/system/boot/mirroredgrubboot.nix

    # pacchetti di sistema
    ../../modules/nixos/system/audio.nix
    ../../modules/nixos/system/virt-manager.nix
    ../../modules/nixos/de/plasma6.nix

    # utenti - !! -
     ../../modules/nixos/users/emoriver.nix

    # servizi
    #../../modules/nixos/services/postgresql.nix
    #../../modules/nixos/services/docker.nix
    #../../modules/nixos/services/vpn.nix
  ];
  

  # ----- rete e localizzazione -----
  networking = {
    hostName = "w541onnixos";
    hostId = "f6118264";
    networkmanager.enable = true;
    wireless.enable = false; # Don't conflict with NetworkManager
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ];
    };

    bridges = {
      "br0" = {
        interfaces = [ "enp0s25" ];
      };
    };

    interfaces = {
      "enp0s25".useDHCP = false;     # L'interfaccia fisica non deve avere IP
      "br0" = {
        useDHCP = true;

        #useDHCP = false;
        #ipv4.addresses = [{
        #  address = "192.168.0.100";
        #  prefixLength = 24;
        #}];
      };
    };

    firewall.trustedInterfaces = [ "br0" ];       # Fondamentale per far passare il traffico della VM verso la CPU Siemens
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
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Stampa/Bluetooth (abilita se ti servono su questo host)
  services.printing.enable = true;   #CUPS
  hardware.bluetooth.enable = true;


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
  ];

  system.stateVersion = "25.05";
}
