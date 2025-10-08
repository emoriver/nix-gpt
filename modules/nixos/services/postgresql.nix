{ config, pkgs, lib, ... }:

let
  cfg = config.services.mysql.custom;

  sqlScript = pkgs.writeText "init.sql" ''
    CREATE USER '${cfg.user}'@'%' IDENTIFIED WITH mysql_native_password BY '${cfg.password}';
    CREATE DATABASE IF NOT EXISTS ${cfg.database};
    GRANT ${cfg.privileges} ON ${cfg.database}.* TO '${cfg.user}'@'%';
  '';

in {
  options.services.mysql.custom = {
    enable = lib.mkEnableOption "Enable custom MySQL setup";
    user = lib.mkOption {
      type = lib.types.str;
      default = "testuser";
      description = "MySQL username";
    };
    password = lib.mkOption {
      type = lib.types.str;
      default = "password";
      description = "MySQL password";
    };
    database = lib.mkOption {
      type = lib.types.str;
      default = "testdb";
      description = "Database name";
    };
    privileges = lib.mkOption {
      type = lib.types.str;
      default = "ALL PRIVILEGES";
      description = "Privileges to grant";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mysql = {
      enable = true;
      package = pkgs.mysql80;
      initialDatabases = [
        {
          name = cfg.database;
          schema = null;
        }
      ];
      initialScript = sqlScript;
      settings = {
        mysqld = {
          "bind-address" = "0.0.0.0";
          "port" = 3306;
        };
      };
    };
  };
}