{ ... }:

{
  services.mympd = {
    enable = true;
    settings = {
      http_port = 80;
      ssl       = false;
      mpd_host  = "/run/user/1001/mpd/socket";
    };
  };

  systemd.services.mympd = {
    after = [ "home-manager-emoriver.service" ];
  };
}