{ config, lib, pkgs, ... }:

let
  cfg = config.apps.logseq;
in {
  options.apps.logseq = {
    enable = lib.mkEnableOption "Abilita Logseq con wrapper senza GPU e launcher grafico (Wayland)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "logseq-nogpu" ''
        # Disabilita GPU e forza backend software su Wayland
        export ELECTRON_DISABLE_GPU=true
        export ELECTRON_ENABLE_LOGGING=true
        export OZONE_PLATFORM=wayland
        export XDG_SESSION_TYPE=wayland
        export QT_QPA_PLATFORM=wayland
        exec ${pkgs.logseq}/bin/logseq \
          --class=logseq \
          --disable-gpu \
          --disable-software-rasterizer \
          --disable-gpu-compositing \
          --in-process-gpu \
          --no-sandbox \
          --enable-features=UseSkiaRenderer,UseOzonePlatform \
          --ozone-platform=wayland
      '')
    ];

    # Copia icona in ~/.local/share/icons
    home.file.".local/share/icons/hicolor/512x512/apps/logseq.png".source =
      "${pkgs.logseq}/share/icons/hicolor/512x512/apps/logseq.png";

    # Desktop entry con StartupWMClass
    home.file.".local/share/applications/logseq-nogpu.desktop".text = ''
      [Desktop Entry]
      Name=Logseq (Wayland No GPU)
      Exec=logseq-nogpu
      Icon=logseq
      Type=Application
      Categories=Office;NoteTaking;
      StartupNotify=true
      StartupWMClass=logseq
    '';
  };
}