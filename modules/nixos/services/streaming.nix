{ config, lib, pkgs, ... }:

# ── Streaming ──────────────────────────────────────────────────────────────
# spotifyd: appare come dispositivo Spotify Connect nella tua app.
#           Scegli "RPI Player" dall'app e la musica esce dal DragonFly.
#
# Credenziali: salvate in /persist/spotifyd-credentials (vedi sotto)
# ───────────────────────────────────────────────────────────────────────────
{
  services.spotifyd = {
    enable = true;
    settings.global = {
      device_name    = "nixerrypie2";
      backend        = "pulseaudio";   # compatibilità PipeWire via pulse socket
      bitrate        = 320;
      initial_volume = "80";
      volume_normalisation = true;
      normalisation_pregain = -10;
      cache_path     = "/var/lib/spotifyd/cache";
      # username = "tuoemail@example.com";
      # password_cmd = "cat /persist/spotify-password";
    };
  };

  # Spotifyd deve accedere alla socket PulseAudio di emoriver
  systemd.services.spotifyd = {
    environment = {
      # UID di emoriver — verifica con: id emoriver
      PULSE_SERVER = "unix:/run/user/1001/pulse/native";
    };
    serviceConfig = {
      User  = "emoriver";
      Group = "audio";
    };
  };

  # Spotifyd gira come utente di sistema, ma ha bisogno di PipeWire
  # Nota: spotifyd di default crea il suo utente, ma deve accedere
  # all'istanza PipeWire dell'utente system o player.
  # La soluzione più semplice è farlo girare come utente player:
  # Spotifyd deve accedere alla socket PulseAudio di emoriver
  systemd.services.spotifyd = {
    environment = {
      # UID di emoriver — verifica con: id emoriver
      PULSE_SERVER = "unix:/run/user/1001/pulse/native";
    };
    serviceConfig = {
      User  = "emoriver";
      Group = "audio";
    };
  };


  # ── SoundCloud ────────────────────────────────────────────────────────────
  # Non esiste un client nativo per SoundCloud su Linux embedded.
  # Il flusso consigliato:
  #
  # 1. Dal tuo PC, ottieni l'URL diretto con yt-dlp:
  #      yt-dlp -g "https://soundcloud.com/artista/traccia"
  #
  # 2. Crea una playlist .m3u in /mnt/musica/playlists/ (o /var/lib/mpd/playlists/)
  #    con l'URL restituito
  #
  # 3. MPD può aprire stream HTTP direttamente — aggiungi in coda:
  #      mpc add "https://...url-diretto..."
  #
  # In alternativa, installa yt-dlp come helper e crea uno script:
  environment.systemPackages = with pkgs; [
    yt-dlp
    (writeShellScriptBin "sc-play" ''
      # Uso: sc-play "https://soundcloud.com/artista/traccia"
      URL=$(${yt-dlp}/bin/yt-dlp -g "$1" 2>/dev/null | head -1)
      if [ -z "$URL" ]; then
        echo "Errore: impossibile ottenere l'URL dello stream" >&2
        exit 1
      fi
      ${mpc-cli}/bin/mpc clear
      ${mpc-cli}/bin/mpc add "$URL"
      ${mpc-cli}/bin/mpc play
    '')
  ];
}
