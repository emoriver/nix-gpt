{ pkgs, pkgsUnstable, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgsUnstable.kiro;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
  };
}
