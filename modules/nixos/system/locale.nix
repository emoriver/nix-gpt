
{ pkgs, ... }:

{
  i18n.defaultLocale = "it_IT.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "it";
  };
  time.timeZone = "Europe/Rome";
}
