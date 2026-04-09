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
    settings = {
      global = {
        # Nome che appare nell'app Spotify
        device_name = "RPI Player";

        # Usa PipeWire (compatibilità PulseAudio)
        backend     = "pulseaudio";

        # Bitrate: 96 = 96kbps, 160 = 160kbps (default), 320 = alta qualità
        bitrate     = 320;

        # Volume iniziale (0-100)
        initial_volume = "80";

        # Normalizzazione volume Spotify (opzionale)
        volume_normalisation    = true;
        normalisation_pregain   = -10;

        # Credenziali da file — NON mettere username/password qui!
        # Il file viene letto da /persist e non finisce nel Nix store.
        # Formato del file (una riga per campo):
        #   [global]
        #   username = tuoemail@example.com
        #   password = tuapassword
        #
        # Oppure usa cache_path con token OAuth (più sicuro):
        cache_path = "/var/lib/spotifyd/cache";

        # username e password: specificali qui oppure usa un file separato
        # username = "tuoemail@example.com";
        # password_cmd = "cat /persist/spotify-password";
      };
    };
  };

  # Spotifyd gira come utente di sistema, ma ha bisogno di PipeWire
  # Nota: spotifyd di default crea il suo utente, ma deve accedere
  # all'istanza PipeWire dell'utente system o player.
  # La soluzione più semplice è farlo girare come utente player:
  systemd.services.spotifyd = {
    environment = {
      # Punta alla socket PipeWire dell'utente player (uid 1000 di default)
      # Verifica con: id player
      PULSE_SERVER = "unix:/run/user/1000/pulse/native";
    };
    serviceConfig = {
      User  = "player";
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
    # Script di esempio installato in PATH:
    (writeShellScriptBin "sc-play" ''
      # Uso: sc-play "https://soundcloud.com/artista/traccia"
      URL=$(${yt-dlp}/bin/yt-dlp -g "$1" 2>/dev/null | head -1)
      if [ -z "$URL" ]; then
        echo "Errore: impossibile ottenere l'URL dello stream" >&2
        exit 1
      fi
      ${mpc}/bin/mpc clear
      ${mpc}/bin/mpc add "$URL"
      ${mpc}/bin/mpc play
    '')
  ];
}
