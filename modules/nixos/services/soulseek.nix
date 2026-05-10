{
  services.slskd = {
    enable = true;
    openFirewall = true;
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
    };
  };

  systemd.services.slskd.serviceConfig = {
    StateDirectory = "slskd";
    ProtectHome = pkgs.lib.mkForce "read-only"; 
    ProtectSystem = pkgs.lib.mkForce "full";
    ReadWritePaths = [ "/mnt/usb_hp_musica/usb_k2/musica/downloads" ];
    
    PrivateDevices = pkgs.lib.mkForce false;
    RestrictNamespaces = pkgs.lib.mkForce false;
  };
}

