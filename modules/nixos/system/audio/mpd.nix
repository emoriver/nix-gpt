{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.myMpdSuite;
in {
  options.services.myMpdSuite = {
    enable = mkEnableOption "Suite Audio MPD + myMPD";

    musicDirectory = mkOption {
      type = types.str;
      description = "Path della cartella musica (usato da MPD).";
    };

    mountUnit = mkOption {
      type = types.str;
      default = "";
      description = "Nome del file .mount di Systemd (opzionale).";
    };

    mountRoot = mkOption {
      type = types.str;
      description = "La radice del mount point da esporre in sola lettura a myMPD.";
    };
  };

  config = mkIf cfg.enable {
    services.mpd = {
      enable         = true;
      user           = "emoriver";
      group          = "audio";
      musicDirectory = cfg.musicDirectory;
      dataDir        = "/var/lib/mpd";
      network.listenAddress = "any";

      settings = {
        # Notare le parentesi quadre [ ... ] che aprono e chiudono la lista
        audio_output = [ {
          type           = "alsa";
          name           = "DragonFly Black";
          device         = "hw:v15,0";
          mixer_type     = "software";
          auto_resample  = "no";
          auto_format    = "no";
          auto_channels  = "no";
          close_on_pause = "yes";
        } ];

        replaygain                       = "auto";
        replaygain_preamp                = "0";
        volume_normalization             = "no";
        zeroconf_enabled                 = "no";
        auto_update                      = "yes";
        auto_update_depth                = "3";
        playlist_directory               = "/var/lib/mpd/playlists";
        save_absolute_paths_in_playlists = "no";
        bind_to_address                  = [ "/run/mpd/socket" "0.0.0.0" ];
        port                             = "6600";
      };
    };

    systemd.services.mpd = {
      after = [ "network.target" ] ++ (optional (cfg.mountUnit != "") cfg.mountUnit);
      wants = optional (cfg.mountUnit != "") cfg.mountUnit;
    };

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
      serviceConfig.BindReadOnlyPaths = [ cfg.mountRoot ];
    };

    users.users.mpd = { isSystemUser = true; group = "audio"; };
    systemd.tmpfiles.rules = [
      "d /var/lib/mpd           0755 emoriver audio -"
      "d /var/lib/mpd/playlists 0755 emoriver audio -"
    ];
  };
}