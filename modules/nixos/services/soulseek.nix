{ config, pkgs, lib, ... }:

{
  services.slskd = {
    enable = true;
    domain = null;
    nginx.enable = false;
    environmentFile = "/etc/slskd/credentials.env";

    settings = {
      ui = {
        web = {
          port = 5030;
          address = "0.0.0.0";
        };
        # non funziona...
        #authentication = {
        #  username = "soul"; 
        #  password = "soul";
        #};
      };

      directories = {
        downloads = "/mnt/usb_hp_musica/downloads";
        incomplete = "/mnt/usb_hp_musica/downloads/incomplete";
      };
      shares = {
        directories = [ "/mnt/usb_hp_musica/usb_k2/musica" ];
      };
    };
  };

  systemd.services.slskd = {
    after = [ "mnt-usb_hp_musica.mount" "network.target" ];
    requires = [ "mnt-usb_hp_musica.mount" ];

    serviceConfig = {
      StateDirectory = "slskd";
      ProtectHome = lib.mkForce "read-only"; 
      ProtectSystem = lib.mkForce "full";
      ReadWritePaths = [ "/mnt/usb_hp_musica/downloads" ];
      
      PrivateDevices = lib.mkForce false;
      RestrictNamespaces = lib.mkForce false;
    };
  };
}