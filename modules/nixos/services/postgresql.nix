{ config, pkgs, lib, ... }:

let
  #backupScript = pkgs.writeShellScript "pg_backup.sh" ''
  #  #!/bin/sh
  #  export PGPASSWORD="password"
  #  pg_dump -U andrea carpinera > /var/backups/postgresql/carpinera.sql
  #'';
in {
  options.myModules.services.postgresql.enable = lib.mkEnableOption "Enable PostgreSQL service";

  config = lib.mkIf config.myModules.services.postgresql.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      dataDir = "/var/lib/postgresql";

      # non funziona nulla da qui in poi...!
      initialScript = pkgs.writeText "init.sql" ''
        CREATE ROLE emoriver WITH LOGIN PASSWORD 'EmoPg25.';
        CREATE DATABASE testdb WITH OWNER emoriver;
      '';

      authentication = ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust

        host    all             all             0.0.0.0/0               md5
        host    all             all             ::/0                    md5
      '';

      extraConfig = ''
        listen_addresses = '*'
        max_connections = 100
        shared_buffers = 256MB
      '';
    };

    /*
    # Backup directory
    systemd.tmpfiles.rules = [
      "d /var/backups/postgresql 0755 andrea users -"
    ];

    # Backup service
    systemd.services.pgBackup = {
      description = "PostgreSQL Backup Service";
      serviceConfig = {
        ExecStart = "${backupScript}";
        User = "andrea";
      };
    };

    # Backup timer (giornaliero alle 3:00)
    systemd.timers.pgBackup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
    */
  };
}