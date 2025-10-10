{ config, lib, pkgs, ... }:

let
  cfg = config.apps.logseq;
in {
  options.apps.logseq = {
    enable = lib.mkEnableOption "Abilita Logseq con wrapper senza GPU e launcher grafico";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "logseq-nogpu" ''
        export ELECTRON_DISABLE_GPU=true
        exec ${pkgs.logseq}/bin/logseq --disable-gpu --in-process-gpu --no-sandbox
      '')
    ];

    home.file.".local/share/applications/logseq-nogpu.desktop".text = ''
      [Desktop Entry]
      Name=Logseq (No GPU)
      Exec=logseq-nogpu
      Icon=logseq
      Type=Application
      Categories=Office;NoteTaking;
      StartupNotify=true
    '';
  };
}
