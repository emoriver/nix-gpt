{ config, lib, pkgs, ... }:

# ── MPD — Music Player Daemon ──────────────────────────────────────────────
# Legge la musica da /mnt/musica (mount SMB opzionale).
# Se il mount non è disponibile, MPD si avvia comunque
# con una libreria vuota e la ricarica quando il mount torna.
# ───────────────────────────────────────────────────────────────────────────
{
  services.mpd = {
    enable         = true;
    user           = "emoriver";
    group          = "audio";
    musicDirectory = "/mnt/usb_hp_musica/usb_k2/musica";
    dataDir        = "/var/lib/mpd";
    network.listenAddress = "any"; 

    extraConfig = ''
      # ── Output audio ────────────────────────────────────────────────────
      audio_output {
        type        "alsa"
        name        "DragonFly Black"
        device      "hw:v15,0"
        mixer_type  "software"
        auto_resample   "no"
        auto_format     "no"
        auto_channels   "no"
        close_on_pause  "yes"
      }

      # ── Qualità ──────────────────────────────────────────────────────────
      replaygain           "auto"
      replaygain_preamp    "0"
      volume_normalization "no"
      zeroconf_enabled     "no"

      # ── Database ─────────────────────────────────────────────────────────
      # MPD non va in errore se la musicDirectory non è montata
      auto_update       "yes"
      auto_update_depth "3"

      # ── Playlist ─────────────────────────────────────────────────────────
      playlist_directory           "/home/emoriver/.config/mpd/playlists"
      save_absolute_paths_in_playlists "no"      
      # ── SoundCloud via yt-dlp ────────────────────────────────────────────
      # Aggiungi URL di stream SoundCloud direttamente come playlist .m3u
      # MPD li risolve con curl; usa yt-dlp per ottenere l'URL diretto:
      #   yt-dlp -g "https://soundcloud.com/..."
    ''; 
  };

  # deve partire dopo che è stato fatto il mount della chiavetta
  systemd.services.mpd = {
    after    = [ "mnt-usb_hp_musica.mount" "network.target" ];
    requires = [ "mnt-usb_hp_musica.mount" ];
  };

  users.users.mpd = {
    isSystemUser = true;
    group        = "audio";
  };

  # Crea le directory necessarie
  systemd.tmpfiles.rules = [
    "d /var/lib/mpd          0755 emoriver audio -"
    "d /var/lib/mpd/playlists 0755 emoriver audio -"
  ];

  systemd.services.mympd.serviceConfig = {
    BindReadOnlyPaths = [ 
      "/mnt/usb_hp_musica/usb_k2/musica:/mnt/usb_hp_musica/usb_k2/musica:rbind"
    ];
  };

  # ── myMPD — Web UI ────────────────────────────────────────────────────────
  # Accessibile da browser su http://rpi-player:80
  services.mympd = {
    enable = true;
    settings = {
      http_port  = 80;
      ssl        = false;
    };  
  };

  # ── Aggiornamento libreria al mount del NAS ────────────────────────────────
  # Quando il mount SMB torna disponibile, notifica MPD di aggiornare
  systemd.services.mpd-update-on-mount = {
    description   = "Aggiorna libreria MPD quando il NAS è montato";
    after         = [ "mnt-musica.mount" ];
    wantedBy      = [ "mnt-musica.mount" ];
    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "${pkgs.mpc}/bin/mpc update";
      User      = "mpd";
    };
  };
}
