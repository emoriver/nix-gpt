{ pkgs }:

pkgs.buildNpmPackage {
  pname = "node-red-packages";
  version = "1.0.0";

  src = ./.;

  npmDepsHash = "sha256-LffDLT83JJrCfAs+LeuPmqsFruKJHFx4mDa9UNc9kB0=";

  dontNpmBuild = true;
}