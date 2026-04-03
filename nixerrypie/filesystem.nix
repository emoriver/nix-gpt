{ config, lib, pkgs, ... }:

# ── Filesystem ─────────────────────────────────────────────────────────────
# Struttura:
#   tmpfs          →  /              (si azzera ad ogni riavvio)
#   /dev/mmcblk0p2 →  /persist       (sopravvive ai riavvii)
#   /dev/mmcblk0p1 →  /boot/firmware (invariata)
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
    # Usa la label che hai assegnato con: e2label /dev/mmcblk0p2 nixos-persist
    device       = "/dev/disk/by-label/nixos-persist";
    fsType       = "ext4";
    options      = [ "relatime" "commit=60" ];  # riduce scritture sulla SD
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
