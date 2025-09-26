
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    neovim
    zsh
    firefox
    htop
    bat
    fd
    ripgrep
  ];
}
