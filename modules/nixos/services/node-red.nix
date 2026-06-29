{ pkgs, ... }:

let
  nodeRedPlugins = import ./node-red-packages/default.nix {
    inherit pkgs;
  };

  nodeModulesPath = "${nodeRedPlugins}/lib/node_modules/node-red-env/node_modules";

in
{
  services.node-red = {
    enable = true;
    port = 1880;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/node-red/node_modules 0755 node-red node-red -"
    "L+ /var/lib/node-red/node_modules/node-red-contrib-opcua - - - - ${nodeModulesPath}/node-red-contrib-opcua"
    "L+ /var/lib/node-red/node_modules/node-red-contrib-modbus - - - - ${nodeModulesPath}/node-red-contrib-modbus"
    "L+ /var/lib/node-red/node_modules/@node-red-contrib-themes - - - - ${nodeModulesPath}/@node-red-contrib-themes"

    # plug-in futuri
    #"L+ /var/lib/node-red/node_modules/<nome> - - - - ${nodeModulesPath}/<nome>"
  ];
}
