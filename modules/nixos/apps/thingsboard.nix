{
  environment.systemPackages = [
    (pkgs.stdenv.mkDerivation {
      pname = "thingsboard";
      version = "3.6.2";

      src = pkgs.fetchurl {
        url = "https://github.com/thingsboard/thingsboard/releases/download/v3.6.2/thingsboard-3.6.2.tar.gz";
        sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      nativeBuildInputs = [ pkgs.makeWrapper ];

      installPhase = ''
        mkdir -p $out
        cp -r * $out/

        # wrapper script
        makeWrapper $out/bin/thingsboard.sh $out/bin/thingsboard \
          --set JAVA_HOME ${pkgs.jdk17}
      '';
    })
  ];
}