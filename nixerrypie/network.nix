{ config, lib, pkgs, ... }:

# ── Rete ───────────────────────────────────────────────────────────────────
# Ethernet via DHCP (consigliato per stabilità audio).
# WiFi configurabile opzionalmente.
# ───────────────────────────────────────────────────────────────────────────
{
  networking = {
    # Ethernet — DHCP automatico
    interfaces.eth0.useDHCP = true;

    # ── WiFi (opzionale) ────────────────────────────────────────────────────
    # Decommentare se si usa WiFi invece di Ethernet.
    # Le credenziali sono in /persist/wpa_supplicant.conf
    #
    # wireless = {
    #   enable = true;
    #   environmentFile = "/persist/wifi-credentials";
    #   networks = {
    #     "NomeRete".psk = "@PSK_NOMRETE@";  # variabile dal file
    #   };
    # };

    # Risoluzione nome locale (rpi-player.local)
    firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 ];   # SSH (MPD e myMPD aperti nel modulo mpd.nix)
    };
  };

  # mDNS — permette di raggiungere il Pi come rpi-player.local
  services.avahi = {
    enable   = true;
    nssmdns4 = true;
    publish = {
      enable      = true;
      addresses   = true;
      workstation = true;
    };
  };

  # Aspetta che la rete sia operativa prima dei mount _netdev
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  systemd.network.wait-online.enable = true;
}
