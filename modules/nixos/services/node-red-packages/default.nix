{ pkgs }:

pkgs.buildNpmPackage {
  pname = "node-red-packages";
  version = "1.0.0";

  src = ./.;

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
``