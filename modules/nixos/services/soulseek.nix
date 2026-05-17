{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mySlskdSuite;
in {
  options.services.mySlskdSuite = {
    enable = mkEnableOption "Configurazione Soulseek (slskd) Parametrizzata";

    musicDirectory = mkOption {
      type = types.str;
      description = "Cartella della musica da condividere (shares).";
    };

    downloadDir = mkOption {
      type = types.str;
      description = "Path dove salvare i download completati.";
    };

    incompleteDir = mkOption {
      type = types.str;
      description = "Path per i download parziali.";
    };

    mountUnit = mkOption {
      type = types.str;
      default = "";
      description = "Nome del file .mount di Systemd (opzionale).";
    };
  };

  config = mkIf cfg.enable {
    services.slskd = {
      enable = true;
      domain = null;
      nginx.enable = false;
      environmentFile = "/etc/slskd/credentials.env";

      settings = {
        ui.web = {
          port = 5030;
          address = "0.0.0.0";
        };
        directories = {
          downloads = cfg.downloadDir;
          incomplete = cfg.incompleteDir;
        };
        shares = {
          directories = [ cfg.musicDirectory ];
        };
      };
    };

    systemd.services.slskd = {
      after = [ "network.target" ] ++ (optional (cfg.mountUnit != "") cfg.mountUnit);
      requires = optional (cfg.mountUnit != "") cfg.mountUnit;

      serviceConfig = {
        StateDirectory = "slskd";
        ProtectHome = lib.mkForce "read-only"; 
        ProtectSystem = lib.mkForce "full";
        ReadWritePaths = [ cfg.downloadDir ];
        PrivateDevices = lib.mkForce false;
        RestrictNamespaces = lib.mkForce false;
      };
    };
  };
}