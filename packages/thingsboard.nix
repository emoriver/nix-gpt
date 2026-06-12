{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "thingsboard";
  version = "4.3.1.2-wrapper";

  # Force rebuild
  rev = "20260612-003";

  src = pkgs.fetchurl {
    url = "https://github.com/thingsboard/thingsboard/releases/download/v4.3.1.2/thingsboard-4.3.1.2.deb";
    sha256 = "0nryixswpx1z6s3rb0wbc8p17d7yyg6376si17v03czvfa0ivfym";
  };

  nativeBuildInputs = [ pkgs.dpkg ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib

    cp usr/share/thingsboard/bin/thingsboard.jar $out/lib/
    cp -r usr/share/thingsboard/conf $out/ 2>/dev/null || true
    cp -r usr/share/thingsboard/data $out/ 2>/dev/null || true

    # Create wrapper script
    cat > $out/bin/thingsboard << EOF
#!/bin/sh
exec ${pkgs.jre}/bin/java -jar $out/lib/thingsboard.jar "\$@"
EOF
    chmod +x $out/bin/thingsboard
  '';
}
