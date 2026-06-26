{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    enableZshIntegration = true;

    #themes = {
    #  tokyonight_night = {
    #    url = "https://raw.githubusercontent.com/tokyo-night/tokyo-night.nvim/main/extras/ghostty/tokyonight_night";
    #    sha256 = "sha256-R8w6jGvG6+9fKThK8P0wTscwI5Pj5uQj9kM0Xk9H3mY="; # Se dà errore di hash al rebuild, te lo correggerà Nix stesso
    #  };
    #};

    settings = {
      #theme = "tokyonight_night";
      #font-family = "JetBrainsMono Nerd Font";
      font-family = "FiraMono Nerd Font";
      font-size = 10;

      background-opacity = 0.80;
      background-blur = true;
      #background-blur-radius = 20;

      window-padding-x = 10;
      window-padding-y = 10;
      window-padding-balance = true;
      window-decoration = false;

      command = "${pkgs.zsh}/bin/zsh";
    };
  };
}
