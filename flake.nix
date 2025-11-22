{
  description = "Configurazione modulare NixOS + Home Manager con host minimale e modulo utente";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;   
    };
    lib = nixpkgs.lib;

    userHomes = {
      #carpinox1vm1 = ./home/emoriver/carpinox1vm1.nix;
      macpnixos = ./home/emoriver/macpnixos.nix;
      w541onnixos = ./home/emoriver/w541onnixos.nix;
      nix-immich-70 = ./home/emoriver/nix-immich-70.nix;
    };
  in
  {
    nixosConfigurations = {
      carpinox1vm1 = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/carpinox1vm1
          home-manager.nixosModules.home-manager
          {
            home-manager.users.emoriver = import userHomes.carpinox1vm1;
          }
        ];
      };

      macpnixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/macpnixos
          home-manager.nixosModules.home-manager
          {
            home-manager.users.emoriver = import userHomes.macpnixos;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      w541onnixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/w541onnixos
          home-manager.nixosModules.home-manager
          {
            home-manager.users.emoriver = import userHomes.w541onnixos;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      nix-immich-70 = lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nix-immich-70
          home-manager.nixosModules.home-manager
          {
            home-manager.users.emoriver = import userHomes.nix-immich-70;
            home-manager.backupFileExtension = "backup";
          }
        ];
      }; 
    };
  };
}