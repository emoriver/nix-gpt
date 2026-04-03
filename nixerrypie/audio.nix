{ config, lib, pkgs, ... }:

# ── Stack audio ────────────────────────────────────────────────────────────
# PipeWire come server audio principale.
# WirePlumber seleziona automaticamente il DragonFly Black USB
# se è l'unico dispositivo audio collegato.
# ───────────────────────────────────────────────────────────────────────────
{
  # Disabilita PulseAudio (incompatibile con PipeWire)
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;  # permette a PipeWire priorità real-time

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = false;  # non serve su aarch64
    pulse.enable      = true;   # compatibilità PulseAudio per spotifyd
    wireplumber.enable = true;
  };

  # ── Configurazione PipeWire per audio HiFi ────────────────────────────────
  # Imposta sample rate e buffer per qualità ottimale con il DragonFly Black
  # (supporta fino a 96kHz/24bit)
  environment.etc."pipewire/pipewire.conf.d/10-dragonfly.conf".text = ''
    context.properties = {
      default.clock.rate          = 96000
      default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
      default.clock.quantum       = 1024
      default.clock.min-quantum   = 512
      default.clock.max-quantum   = 2048
    }
  '';

  # WirePlumber: forza il DragonFly come sink predefinito
  # (identificato dal nome USB, puoi verificarlo con: pw-cli list-objects)
  environment.etc."wireplumber/wireplumber.conf.d/10-dragonfly-default.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          { node.nick = "~.*DragonFly.*" }
          { node.nick = "~.*Dragonfly.*" }
        ]
        actions = {
          update-props = {
            priority.session = 1000
            node.description = "AudioQuest DragonFly Black"
          }
        }
      }
    ]
  '';
}
