{ config, pkgs, ... }:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    #boot
    ../../modules/nixos/system/boot/mirrorgrubboot_w541.nix

    # pacchetti di sistema
    ../../modules/nixos/system/audio
    ../../modules/nixos/system/virt-manager.nix
    ../../modules/nixos/de/plasma6.nix
    ../../modules/nixos/de/niri.nix

    # utenti - !! -
    ../../modules/nixos/users/emoriver.nix

    # servizi
    #../../modules/nixos/services/postgresql.nix
    #../../modules/nixos/services/docker.nix
    #../../modules/nixos/services/vpn.nix
  ];

  # Grafica ibrida Intel + Nvidia
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # scaldava troppo...
  /*
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true; # spegne la GPU quando non usata
      open = false;
      nvidiaSettings = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true; # abilita il comando nvidia-offload
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    # Nvidia power management - Quadro K2100M
    services.udev.extraRules = ''
      ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
    '';
  */

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ----- rete e localizzazione -----
  networking = {
    hostName = "w541onnixos";
    hostId = "f6118264";
    networkmanager.enable = true;
    #wireless.enable = false; # Don't conflict with NetworkManager
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
      "enp0s25".useDHCP = false; # L'interfaccia fisica non deve avere IP
      "br0" = {
        useDHCP = true;

        #useDHCP = false;
        #ipv4.addresses = [{
        #  address = "192.168.0.100";
        #  prefixLength = 24;
        #}];
      };
    };

    firewall.trustedInterfaces = [ "br0" ]; # Fondamentale per far passare il traffico della VM verso la CPU Siemens
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "it_IT.UTF-8";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "it_IT.UTF-8/UTF-8"
    ];
  };
  #location.provider = "geoclue2";
  time.timeZone = "Europe/Rome";

  # ----- impostazioni di nix -----
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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

  # Stampa
  services.printing.enable = true; # CUPS

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

  system.stateVersion = "25.11";
}
