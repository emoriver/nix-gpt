{ lib, ... }:
{
  services.mympd = {
    enable = true;
    settings = {
      http_port = 80;
      ssl = false;
      mpd_host = "/run/user/1000/mpd/socket";
    };
  };

  systemd.services.mympd = {
    environment.MPD_HOST = "/run/user/1000/mpd/socket";
    serviceConfig = {
      User = lib.mkForce "emoriver";
      Group = lib.mkForce "users";
      DynamicUser = lib.mkForce false;
      ProtectHome = lib.mkForce "no";
      BindReadOnlyPaths = [
        "/mnt"
        "/run/user/1000/mpd"
      ];
      StateDirectory = lib.mkForce "";
      RuntimeDirectory = lib.mkForce "";
    };
  };

  system.activationScripts.myMpdState = ''
    if [ -f /var/lib/mympd/state/default/mpd_host ]; then
      current=$(cat /var/lib/mympd/state/default/mpd_host)
      if [ "$current" != "/run/user/1000/mpd/socket" ]; then
        rm -rf /var/lib/mympd/state/
      fi
    fi
  '';

}
