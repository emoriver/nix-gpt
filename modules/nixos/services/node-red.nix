{ config, pkgs, ... }:

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

  systemd.services.node-red = {
    environment = {
      NODE_PATH = "${nodeRedPlugins}/lib/node_modules/node-red-env/node_modules";
    };
  };
}