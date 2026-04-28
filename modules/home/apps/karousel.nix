{ config, pkgs, lib, ... }:

let
  karousel-src = pkgs.fetchFromGitHub {
    owner = "peterfajdiga";
    repo = "karousel";
    rev = "master";
    sha256 = "14rbg3phnfar4hnj292w5aakqq3iyww0wsqrnqnv1q9h1xyzg6vc";
  };

  karousel-install = pkgs.stdenv.mkDerivation {
    name = "karousel-kwin-script";
    src = karousel-src;

    buildPhase = "true"; # Nessuna build necessaria
    installPhase = ''
      mkdir -p $out/share/kwin/scripts/karousel
      cp -r * $out/share/kwin/scripts/karousel

      # Creazione del file metadata.json
      cat > $out/share/kwin/scripts/karousel/metadata.json <<EOF
{
    "KPlugin": {
        "Id": "karousel",
        "Name": "Karousel",
        "Description": "Scrollable tiling layout for KWin",
        "Version": "1.0",
        "License": "GPL",
        "EnabledByDefault": false
    }
}
EOF

      # Creazione della struttura contents/config/main.xml
      mkdir -p $out/share/kwin/scripts/karousel/contents/config
      cat > $out/share/kwin/scripts/karousel/contents/config/main.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<kcfg xmlns="http://www.kde.org/standards/kcfg/1.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.kde.org/standards/kcfg/1.0
                          http://www.kde.org/standards/kcfg/1.0/kcfg.xsd">
    <kcfgfile name="karouselrc"/>
    <group name="General">
        <!-- Nessuna opzione per ora -->
    </group>
</kcfg>
EOF

      # Creazione della struttura contents/ui/config.ui con QML di base
      mkdir -p $out/share/kwin/scripts/karousel/contents/ui
      cat > $out/share/kwin/scripts/karousel/contents/ui/config.ui <<EOF
import QtQuick 2.0
import QtQuick.Controls 2.0

Item {
    width: 400
    height: 300
    Label {
        text: "Karousel non ha opzioni di configurazione."
        anchors.centerIn: parent
    }
}
EOF
    '';
  };
in
{
  options.karousel.enable = lib.mkEnableOption "Enable KDE Karousel KWin script";

  config = lib.mkIf config.karousel.enable {
    home.packages = [ karousel-install ];

    home.activation.karouselScript = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ~/.local/share/kwin/scripts/karousel
      cp -r ${karousel-install}/share/kwin/scripts/karousel/* ~/.local/share/kwin/scripts/karousel/
    '';
  };
}
