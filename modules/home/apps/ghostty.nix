{ config, pkgs, ... }:

{
programs.ghostty = {
    enable = true;
    enableZshIntegration = true; 
    
    settings = {
      theme = "tokyonight-night";
      font-family = config.fontProfiles.monospace.name;
      font-size = 11;
      window-padding-x = 10;
      window-padding-y = 10;
      command = "${pkgs.zsh}/bin/zsh";
    };
  };
}