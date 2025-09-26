{
  description = "Configurazione modulare NixOS + Home Manager per host e utenti specifici";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        lib = pkgs.lib;

        # Configurazioni per host
        hostConfigs = {
          host__1__ = ./hosts/host__1__/configuration.nix;
          host__2__ = ./hosts/host__2__/configuration.nix;
        };

        # Configurazioni Home Manager per utenti per host specifico
        userHomes = {
          emoriver_host__1__ = ./home/emoriver/host__1__.nix;
          emoriver_host__2__ = ./home/emoriver/host__2__.nix;
          user2_host__2__ = ./home/user2/host__2__.nix;
        };
      in {
        nixosConfigurations = {
          host__1__ = lib.nixosSystem {
            inherit system;
            modules = [
              hostConfigs.host__1__
              home-manager.nixosModules.home-manager
              {
                home-manager.users.emoriver = import userHomes.emoriver_host__1__;
              }
            ];
          };

          host__2__ = lib.nixosSystem {
            inherit system;
            modules = [
              hostConfigs.host__2__
              home-manager.nixosModules.home-manager
              {
                home-manager.users.emoriver = import userHomes.emoriver_host__2__;
                home-manager.users.user2 = import userHomes.user2_host__2__;
              }
            ];
          };
        };
      }
    );
}