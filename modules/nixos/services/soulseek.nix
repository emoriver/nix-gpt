{ config, pkgs, lib, ... }:

{
  services.slskd = {
    enable = true;
    domain = null;
    nginx.enable = false;
    environmentFile = "/etc/slskd/credentials.env";

    settings = {
      directories = {
        downloads = "/mnt/usb_hp_musica/usb_k2/musica/downloads";
        incomplete = "/mnt/usb_hp_musica/usb_k2/musica/downloads/incomplete";
      };
      shares = {
        directories = [ "/mnt/usb_hp_musica/usb_k2/musica" ];
      };
      authentication = {
        username = "soul"; 
        password = "soul";
      };
    };
  };

  systemd.services.slskd.serviceConfig = {
    StateDirectory = "slskd";
    
    ProtectHome = lib.mkForce "read-only"; 
    ProtectSystem = lib.mkForce "full";
    ReadWritePaths = [ "/mnt/usb_hp_musica/usb_k2/musica/downloads" ];
    
    PrivateDevices = lib.mkForce false;
    RestrictNamespaces = lib.mkForce false;
  };
}

