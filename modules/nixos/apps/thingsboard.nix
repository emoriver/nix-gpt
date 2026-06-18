{ config, pkgs, lib, ... }:

{
  systemd.services.thingsboard = {
    description = "ThingsBoard IoT Platform";
    after = [ "network.target" "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "thingsboard";
      EnvironmentFile = "/var/lib/thingsboard/conf/thingsboard.env";
      ExecStart = "${pkgs.jdk21}/bin/java "
        + "-Dplatform=deb "
        + "-Dinstall.data_dir=/usr/share/thingsboard/data "
        + "-XX:+UseG1GC -XX:MaxGCPauseMillis=500 "
        + "-Dloader.path=/usr/share/thingsboard/conf,/usr/share/thingsboard/extensions "
        + "-Dspring.config.location=file:/usr/share/thingsboard/conf/thingsboard.yml "
        + "-jar /usr/share/thingsboard/bin/thingsboard.jar";
      WorkingDirectory = "/usr/share/thingsboard";
      SuccessExitStatus = 143;
      Restart = "always";
      RestartSec = 30;
    };
  };
}