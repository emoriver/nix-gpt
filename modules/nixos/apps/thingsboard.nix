{ config, pkgs, lib, ... }:

let
  cfg = config.services.thingsboard;
  tbPkg = pkgs.callPackage ../packages/thingsboard.nix {};
in
{
  options.services.thingsboard = {
    enable = lib.mkEnableOption "ThingsBoard";

    /*database = {
      host = lib.mkOption { default = "localhost"; };
      port = lib.mkOption { default = 5432; };
      name = lib.mkOption { default = "thingsboard"; };
      user = lib.mkOption { default = "tbuser"; };
      password = lib.mkOption { default = "password"; };
    };*/
  };

  config = lib.mkIf cfg.enable {

    users.groups.thingsboard = {};

    users.users.thingsboard = {
      isSystemUser = true;
      group = "thingsboard";
      home = "/var/lib/thingsboard";
      createHome = true;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/thingsboard 0755 thingsboard thingsboard -"
    ];

    systemd.services.thingsboard = {
      description = "ThingsBoard";
      after = [ "network.target" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "thingsboard";
        WorkingDirectory = "/var/lib/thingsboard";
        ExecStart = "${tbPkg}/bin/thingsboard";
        Restart = "always";
      };

      /*environment = {
        DATABASE_TS_TYPE = "sql";
        SPRING_DATASOURCE_URL =
          "jdbc:postgresql://${cfg.database.host}:${toString cfg.database.port}/${cfg.database.name}";
        SPRING_DATASOURCE_USERNAME = cfg.database.user;
        SPRING_DATASOURCE_PASSWORD = cfg.database.password;
      };*/
    };
  };
}