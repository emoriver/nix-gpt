{ config, lib, ... }:

with lib;
let
  cfg = config.services.myMpdSuite;
in
{
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
      enable = true;
      user = "emoriver";
      group = "audio";
      dataDir = "/var/lib/mpd";
      openFirewall = false;
      startWhenNeeded = true; # ← crea /run/mpd/socket automaticamente
      network.listenAddress = "any"; # ascolta anche su TCP

      settings = {
        music_directory = cfg.musicDirectory;

        audio_output = [
          {
            type = "alsa";
            name = "DragonFly Black";
            device = "hw:v15,0";
            mixer_type = "software";
            auto_resample = "no";
            auto_format = "no";
            auto_channels = "no";
            close_on_pause = "yes";
          }
        ];

        port = 6600;
        replaygain = "auto";
        replaygain_preamp = "0";
        volume_normalization = false;
        zeroconf_enabled = false;
        auto_update = true;
        auto_update_depth = 3;
        playlist_directory = "/var/lib/mpd/playlists";
        save_absolute_paths_in_playlists = false;
      };
    };

    systemd.sockets.mpd-unix = {
      wantedBy = [ "sockets.target" ];
      before = [ "mpd.service" ];
      socketConfig = {
        ListenStream = "/run/mpd/socket";
        SocketMode = "0666";
        DirectoryMode = "0755";
      };
    };

    systemd.services.mpd = {
      wantedBy = lib.mkForce [ ];
      requires = [ "mpd-unix.socket" ];
      after = [
        "mpd-unix.socket"
        "network.target"
      ]
      ++ (optional (cfg.mountUnit != "") cfg.mountUnit);
      wants = optional (cfg.mountUnit != "") cfg.mountUnit;
    };

    services.mympd = {
      enable = true;
      settings = {
        http_port = 80;
        ssl = false;
        mpd_host = "/run/mpd/socket";
      };
    };

    systemd.services.mympd = {
      after = [ "mpd.service" ];
      serviceConfig.BindReadOnlyPaths = [ cfg.mountRoot ];
    };

    users.users.mpd = {
      isSystemUser = true;
      group = "audio";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/mpd           0755 emoriver audio -"
      "d /var/lib/mpd/playlists 0755 emoriver audio -"
    ];
  };
}
