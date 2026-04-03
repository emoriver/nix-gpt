# RPI Audio Player — NixOS setup

## Struttura file

```
nixos-rpi/
├── flake.nix                  # entry point, dipendenze
├── configuration.nix          # configurazione principale
└── modules/
    ├── filesystem.nix         # tmpfs root, /persist, mount SMB
    ├── audio.nix              # PipeWire + DragonFly Black
    ├── mpd.nix                # MPD + myMPD web UI
    ├── streaming.nix          # spotifyd + helper SoundCloud
    ├── network.nix            # rete, mDNS
    └── persist.nix            # impermanence — cosa sopravvive ai riavvii
```

---

## Migrazione da NixOS standard a impermanence

### Passo 1 — Prepara la partizione /persist

```bash
# Dai un'etichetta alla partizione root attuale
sudo e2label /dev/mmcblk0p2 nixos-persist

# Verifica
sudo blkid /dev/mmcblk0p2
```

### Passo 2 — Copia la configurazione

```bash
# Crea la struttura di directory su /persist
sudo mkdir -p /persist/etc/nixos

# Copia questa cartella in /persist
sudo cp -r /etc/nixos/nixos-rpi /persist/etc/nixos/

# Copia host keys SSH (così non cambia fingerprint dopo il riavvio)
sudo mkdir -p /persist/etc/ssh
sudo cp /etc/ssh/ssh_host_* /persist/etc/ssh/

# Copia machine-id
sudo cp /etc/machine-id /persist/etc/machine-id
sudo cp /etc/adjtime    /persist/etc/adjtime
```

### Passo 3 — Punta /etc/nixos al flake

```bash
# Rimuovi la vecchia configurazione (o fai backup)
sudo mv /etc/nixos /etc/nixos.bak

# Crea symlink alla posizione persistente
sudo ln -s /persist/etc/nixos /etc/nixos
```

### Passo 4 — Applica la configurazione

```bash
cd /persist/etc/nixos/nixos-rpi

# Prima build con il nuovo flake
sudo nixos-rebuild switch --flake .#rpi-player

# Se va a buon fine, riavvia
sudo reboot
```

### Passo 5 — Verifica dopo il riavvio

```bash
# / deve essere tmpfs
findmnt /
# → tmpfs on / type tmpfs

# /persist deve essere la SD
findmnt /persist
# → /dev/mmcblk0p2 on /persist type ext4

# MPD deve essere attivo
systemctl status mpd

# myMPD raggiungibile da browser su:
# http://rpi-player.local
```

---

## Configurazione credenziali (dopo il primo riavvio)

### NAS SMB

```bash
sudo nano /persist/smb-credentials
# Inserisci:
#   username=tuoutente
#   password=tuapassword
#   domain=WORKGROUP

sudo chmod 600 /persist/smb-credentials
```

### Spotify

```bash
# Metodo 1: password in chiaro (semplice)
echo "tuapassword" | sudo tee /persist/spotify-password
sudo chmod 600 /persist/spotify-password
sudo chown player:audio /persist/spotify-password

# Poi decommenta in streaming.nix:
#   password_cmd = "cat /persist/spotify-password";

# Metodo 2: OAuth (più sicuro, nessuna password salvata)
# Avvia spotifyd manualmente la prima volta e segui le istruzioni:
# sudo -u player spotifyd --no-daemon
```

### SoundCloud

```bash
# Riproduci una traccia SoundCloud da riga di comando:
sc-play "https://soundcloud.com/artista/titolo-traccia"

# Oppure aggiungi manualmente alla coda MPD:
URL=$(yt-dlp -g "https://soundcloud.com/..." | head -1)
mpc add "$URL" && mpc play
```

---

## Controllo da smartphone

- **Android**: MPDroid (F-Droid / Play Store)
- **iOS**: MPaD, Rigelian
- **Browser**: http://rpi-player.local (myMPD)
- **Terminale**: `ncmpc` o `mpc` (già installati)

---

## Aggiornamenti NixOS

```bash
cd /persist/etc/nixos/nixos-rpi

# Aggiorna le dipendenze
nix flake update

# Applica
sudo nixos-rebuild switch --flake .#rpi-player
```

Gli aggiornamenti sono sicuri: se qualcosa va storto, riavvia e
il sistema torna alla generazione precedente (il boot loader
mantiene le ultime generazioni).

---

## Troubleshooting

**MPD non vede la musica**
```bash
systemctl status mnt-musica.mount
mpc update  # forza aggiornamento libreria
```

**DragonFly non viene rilevato**
```bash
pw-cli list-objects | grep -i dragon  # verifica nome esatto
# Aggiorna il nick nel modulo audio.nix se necessario
```

**spotifyd non si connette**
```bash
journalctl -u spotifyd -f
# Verifica le credenziali in /persist/spotify-password
```
