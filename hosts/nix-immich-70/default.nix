{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [ 
    (modulesPath + "/virtualisation/proxmox-lxc.nix")

    # pacchetti di sistema
    #../../modules/nixos/system/audio.nix
    #../../modules/nixos/de/plasma6.nix

    # utenti - !! -
     ../../modules/nixos/users/emoriver.nix

    # servizi
    #../../modules/nixos/services/postgresql.nix
    ../../modules/nixos/services/docker.nix
    #../../modules/nixos/services/vpn.nix
    ../../modules/nixos/services/samba.nix
  ];
  
  nix.settings = { sandbox = false; };  
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };

  users.users.emoriver = {
    isNormalUser = true;
    home = "/home/emoriver";
    extraGroups = [ "wheel" "networkmanager" "sudo" ];
    shell = pkgs.zsh;
    initialPassword = "nixos";
  };

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

  environment.systemPackages = with pkgs; [
    #vim
    git 
    curl 
    wget 
    htop 
    #btop 
    ripgrep 
    fd 
    unzip 
    zip 
    gnupg 
    tmux
  ];

  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  services.openssh = {
    enable = true;
    settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "no";
        ClientAliveInterval = 300;
        ClientAliveCountMax = 3;
        };
  };

  # Cache DNS lookups to improve performance
  services.resolved = {
    extraConfig = ''
      Cache=true
      CacheFromLocalhost=true
    '';
  };

  systemd.mounts = [{
    where = "/sys/kernel/debug";
    enable = false;
  }];

  system.stateVersion = "25.05";
}
