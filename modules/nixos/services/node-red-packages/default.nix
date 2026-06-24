{ pkgs }:

pkgs.buildNpmPackage {
  pname = "node-red-packages";
  version = "1.0.0";

  src = ./.;

  npmDepsHash = "sha256-V9Y8SSRbPIxUncQc68Bk/wYXbmAohsYqnuW/6ElcUbs=";

  dontNpmBuild = true;
}