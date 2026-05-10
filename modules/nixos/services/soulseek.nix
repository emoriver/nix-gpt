{
    services.slskd = {
        enable = true;
        openFirewall = true; # Apre le porte per i download e l'interfaccia web
        domain = "192.168.88.192";
        environmentFile = "/etc/slskd/credentials.env";
        settings = {
            directories = {
                # Dove scaricherai la musica (magari sulla tua nuova chiavetta USB!)
                downloads = "/mnt/usb_hp_musica/usb_k2/musica/downloads";
                incomplete = "/mnt/usb_hp_musica/usb_k2/musica/downloads/incomplete";
            };
            sharing = {
                directories = [ "/mnt/usb_hp_musica/usb_k2/musica" ]; # Condividi la tua libreria (fondamentale su Soulseek)
            };
            ui = {
                web = {
                    port = 5030;
                };
            };
        };
        systemd.services.slskd.serviceConfig.StateDirectory = "slskd";
    };
}