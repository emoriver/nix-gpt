
{ pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    noto-fonts
    fira-code
    nerdfonts
  ];
}
