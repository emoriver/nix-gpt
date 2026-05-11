{ config, lib, pkgs, ... }:

{
  services.mpd = {
    enable         = true;
    user           = "emoriver";
    group          = "audio";
    musicDirectory = "/mnt/usb_hp_musica/usb_k2/musica";
    dataDir        = "/var/lib/mpd";
    network.listenAddress = "any";

    extraConfig = ''
      audio_output {
        type          "alsa"
        name          "DragonFly Black"
        device        "hw:v15,0"
        mixer_type    "software"
        auto_resample "no"
        auto_format   "no"
        auto_channels "no"
        close_on_pause "yes"
      }

      replaygain           "auto"
      replaygain_preamp    "0"
      volume_normalization "no"
      zeroconf_enabled     "no"

      auto_update       "yes"
      auto_update_depth "3"

      playlist_directory           "/var/lib/mpd/playlists"
      save_absolute_paths_in_playlists "no"

      bind_to_address "/run/mpd/socket"

      bind_to_address "0.0.0.0"
      port "6600"
    '';
  };

  # MPD parte dopo il mount della chiavetta musica
  systemd.services.mpd = {
    after  = [ "mnt-usb_hp_musica.mount" "network.target" ];
    wants  = [ "mnt-usb_hp_musica.mount" ];  # wants invece di requires — non blocca se assente
  };

  users.users.mpd = {
    isSystemUser = true;
    group        = "audio";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/mpd           0755 emoriver audio -"
    "d /var/lib/mpd/playlists 0755 emoriver audio -"
  ];

  # ── myMPD — Web UI ──────────────────────────────────────────────────────
  services.mympd = {
    enable = true;
    settings = {
      http_port = 80;
      ssl       = false;
      mpd_host  = "/run/mpd/socket";
    };
  };

  systemd.services.mympd = {
    after         = [ "mpd.service" ];
    serviceConfig = {
      BindReadOnlyPaths = [ "/mnt/usb_hp_musica" ];
    };
  };
}