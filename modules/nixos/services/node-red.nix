{ pkgs, ... }:

let
  nodeRedPlugins = import ./node-red-packages/default.nix {
    inherit pkgs;
  };
in
{
  services.node-red = {
    enable = true;
    port = 1880;
  };

  environment.systemPackages = [
    nodeRedPlugins
  ];
}