{
  description = "NixOS audio player — Raspberry Pi 4B";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-24.11";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, ... }: {
    nixosConfigurations.rpi-player = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        impermanence.nixosModules.impermanence
        ./configuration.nix
      ];
    };
  };
}
