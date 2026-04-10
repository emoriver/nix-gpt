{ config, lib, pkgs, ... }:

# ── MPD — Music Player Daemon ──────────────────────────────────────────────
# Legge la musica da /mnt/musica (mount SMB opzionale).
# Se il mount non è disponibile, MPD si avvia comunque
# con una libreria vuota e la ricarica quando il mount torna.
# ───────────────────────────────────────────────────────────────────────────
{
  services.mpd = {
    enable        = true;
    user          = "mpd";
    musicDirectory = "/mnt/musica";
    dataDir       = "/var/lib/mpd";  # persiste tramite /persist

    extraConfig = ''
      # ── Output audio ────────────────────────────────────────────────────
      audio_output {
        type        "pipewire"
        name        "DragonFly Black"
        device      "plughw:v15"
      }

      # ── Qualità ──────────────────────────────────────────────────────────
      audio_output_format   "96000:24:2"
      replaygain            "auto"
      replaygain_preamp     "0"
      volume_normalization  "no"   # usa ReplayGain, non normalizzazione brutale

      # ── Rete ─────────────────────────────────────────────────────────────
      #bind_to_address  "0.0.0.0"
      #port             "6600"      # genera un errore di porta già in uso!

      # ── Database ─────────────────────────────────────────────────────────
      # MPD non va in errore se la musicDirectory non è montata
      auto_update         "yes"
      auto_update_depth   "3"

      # ── Playlist ─────────────────────────────────────────────────────────
      playlist_directory  "/var/lib/mpd/playlists"
      save_absolute_paths_in_playlists "no"

      # ── SoundCloud via yt-dlp ────────────────────────────────────────────
      # Aggiungi URL di stream SoundCloud direttamente come playlist .m3u
      # MPD li risolve con curl; usa yt-dlp per ottenere l'URL diretto:
      #   yt-dlp -g "https://soundcloud.com/..."
    '';
  };

  # MPD deve poter leggere i file montati via NAS
  users.users.mpd.extraGroups = [ "audio" "pipewire" "video" ];

  # ── myMPD — Web UI ────────────────────────────────────────────────────────
  # Accessibile da browser su http://rpi-player:80
  services.mympd = {
    enable = true;
    settings = {
      http_port  = 80;
      ssl        = false;
    };

    # permesso all'utente mpd di accedere alle config di emoriver (utente 1002)
    environment = {
      "PULSE_SERVER" = "unix:/run/user/1002/pulse/native";
      "PIPEWIRE_RUNTIME_DIR" = "/run/user/1002";
      "PIPEWIRE_LATENCY" = "512/96000";
    };    
  };

  # Apri le porte nel firewall
  networking.firewall.allowedTCPPorts = [
    6600   # MPD
    80     # myMPD web UI
  ];

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
