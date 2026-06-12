{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "thingsboard";
  version = "4.3.1.2";

  src = pkgs.fetchurl {
    url = "https://github.com/thingsboard/thingsboard/releases/download/v4.3.1.2/thingsboard-4.3.1.2.deb";
    sha256 = "0nryixswpx1z6s3rb0wbc8p17d7yyg6376si17v03czvfa0ivfym";
  };

  nativeBuildInputs = [ pkgs.dpkg pkgs.makeWrapper ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out
    cp -r usr/share/thingsboard/* $out/
  '';
}
