
{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Emoriver";
    userEmail = "emoriver@host__1__.local";
    extraConfig = {
      core.editor = "nvim";
    };
  };
}
