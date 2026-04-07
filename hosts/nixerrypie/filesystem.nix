{ config, lib, pkgs, ... }:

# ── Filesystem ─────────────────────────────────────────────────────────────
# Struttura:
# SD card (mmcblk0)
# ├── p1  vfat   /boot/firmware   (boot, read-only nella pratica)
# └── p2  ext4   /nix/store       (generazioni NixOS, read-only dopo il boot)

# Chiavetta USB (sda)
# └── p1  ext4   /persist         (tutto quello che sopravvive ai riavvii)

# RAM
# └── tmpfs      /                (root effimera, si azzera ad ogni riavvio)

#   //nas/musica   →  /mnt/musica    (opzionale, nofail)
# ───────────────────────────────────────────────────────────────────────────
{
  fileSystems."/" = {
    device  = "none";
    fsType  = "tmpfs";
    options = [
      "defaults"
      "size=512M"   # adatta in base alla RAM disponibile (4GB → puoi alzare)
      "mode=755"
    ];
  };

  fileSystems."/persist" = {
    device       = "/dev/disk/by-label/persist";  # label sulla chiavetta
    fsType       = "ext4";
    options      = [ "relatime" "commit=60" ];
    neededForBoot = true;
  };

  fileSystems."/boot/firmware" = {
    device  = "/dev/disk/by-label/BOOT";
    fsType  = "vfat";
    options = [ "defaults" ];
  };

  # ── Mount NAS / USB esterno via SMB ───────────────────────────────────────
  # Il mount è opzionale: nofail + automount garantiscono che il sistema
  # si avvii normalmente anche se il NAS non è raggiungibile.
  #
  # Crea il file delle credenziali in /persist/smb-credentials con:
  #   username=tuoutente
  #   password=tuapassword
  # Poi: chmod 600 /persist/smb-credentials
  fileSystems."/mnt/musica" = {
    device  = "//192.168.1.X/musica";   # ← cambia con IP e share del tuo NAS
    fsType  = "cifs";
    options = [
      "credentials=/persist/smb-credentials"
      "uid=${toString config.users.users.mpd.uid}"  # MPD può leggere i file
      "gid=audio"
      "iocharset=utf8"
      "vers=3.0"
      "nofail"                          # non blocca il boot se assente
      "_netdev"                         # aspetta la rete prima di montare
      "x-systemd.automount"             # monta solo quando viene acceduto
      "x-systemd.idle-timeout=60"       # smonta dopo 60s di inattività
      "x-systemd.mount-timeout=10"      # timeout connessione NAS
      "x-systemd.requires=network-online.target"
    ];
  };

  # Assicura che systemd aspetti la rete prima del mount
  systemd.services."mnt-musica.mount" = {
    after   = [ "network-online.target" ];
    wants   = [ "network-online.target" ];
  };

  # Pacchetti necessari per CIFS
  environment.systemPackages = [ pkgs.cifs-utils ];
}
