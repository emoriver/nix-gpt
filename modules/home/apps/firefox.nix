
{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "https://nixos.org";
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };
}
