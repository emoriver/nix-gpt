{ cfg, lib, ... }:

{
  services.mympd = {
    enable = true;
    settings = {
      http_port = 80;
      ssl = false;
      mpd_host = "/run/user/1001/mpd/socket"; # socket utente
    };
  };

  systemd.services.mympd = {
    after = [ "home-manager-emoriver.service" ];
    serviceConfig.BindReadOnlyPaths = [ cfg.mountRoot ];
  };

  networking.firewall.allowedTCPPorts = [
    6600
    80
  ];
}
