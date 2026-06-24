{ pkgs, ... }:

{
  # ----- imports -----
  imports = [
    ./hardware-configuration.nix

    # pacchetti di sistema
    ../../modules/nixos/system/audio
    ../../modules/nixos/system/virt-manager.nix
    ../../modules/nixos/system/virt-manager.nix
    ../../modules/nixos/de/plasma6.nix
    ../../modules/nixos/de/niri.nix

    # utenti
    ../../modules/nixos/users/emoriver.nix
    ../../modules/nixos/users/carpinera.nix

    # servizi
    ../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/node-red.nix
    #../../modules/nixos/apps/thingsboard.nix
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

  hardware.bluetooth.enable = true;

  #services.xserver.videoDrivers = [ "amdgpu" ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;  # power-profiles-daemon gestisce i profili energetici (bilanciato, risparmio, performance)

  # ----- rete e localizzazione -----
  networking = {
    hostName = "p16s1onnixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22 # SSH
        1880 # Node-RED
      ];

      # allowedUDPPorts = [ ];
    };
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

  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.overrideAttrs (old: {
        doCheck = false; # Salta i test unitari di Rust che falliscono sul Trashcan
      });
    })
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
      AllowUsers = [
        "emoriver"
        "carpinera"
      ];
    };
  };

  # Stampa/Bluetooth
  #services.printing.enable = true;   #CUPS

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;

    extensions = ps: [ ps.timescaledb ];

    settings = {
      shared_preload_libraries = "timescaledb";
    };
  };

  enableDocker = true;

  systemd.services.thingsboard = {
    description = "ThingsBoard IoT Platform";
    after = [
      "network.target"
      "postgresql.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "thingsboard";
      EnvironmentFile = "/var/lib/thingsboard/conf/thingsboard.env";
      ExecStart =
        "${pkgs.jdk21}/bin/java "
        + "-Dplatform=deb "
        + "-Dinstall.data_dir=/usr/share/thingsboard/thingsboard/data "
        + "-XX:+UseG1GC -XX:MaxGCPauseMillis=500 "
        + "-Dloader.path=/usr/share/thingsboard/thingsboard/conf,/usr/share/thingsboard/thingsboard/extensions "
        + "-Dspring.config.location=file:/usr/share/thingsboard/thingsboard/conf/thingsboard.yml "
        + "-jar /usr/share/thingsboard/thingsboard/bin/thingsboard.jar";
      WorkingDirectory = "/usr/share/thingsboard";
      SuccessExitStatus = 143;
      #Restart = "always";
      #RestartSec = 30;
    };
  };

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

    lm_sensors # For temperature/fan monitoring
    mission-center # Modern system monitor with thermal info

    jdk21
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
