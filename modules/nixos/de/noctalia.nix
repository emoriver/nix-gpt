{ ... }:

{
  # Servizi richiesti da noctalia-shell
  # https://noctalia-dev.github.io/noctalia-shell/docs/getting-started/nixos

  #hardware.bluetooth.enable = true;

  services.upower.enable = true;

  # power-profiles-daemon gestisce i profili energetici (bilanciato, risparmio, performance)
  # su hardware che lo supporta. Alternativa: services.tuned.enable = true;
  services.power-profiles-daemon.enable = true;
}
