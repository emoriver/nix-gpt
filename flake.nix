{
  description = "NixOS + Home Manager multi-host multi-user";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils, ... }:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    hosts = {
      macpnixos = {
        hostModule = ./hosts/macpnixos;
        users = {
          emoriver = ./home/emoriver/macpnixos.nix;
        };
      };
      nix-immich-70 = {
        hostModule = ./hosts/nix-immich-70;
        users = {
          emoriver = ./home/emoriver/nix-immich-70.nix;
        };
      };
      w541onnixos = {
        hostModule = ./hosts/w541onnixos;
        users = {
          #carpinera = ./home/carpinera/w541onnixos.nix;
          emoriver = ./home/emoriver/w541onnixos.nix;
        };
      };      
      t4801onnixos = {
        hostModule = ./hosts/t4801onnixos;
        users = {
          carpinera = ./home/carpinera/t4801onnixos.nix;
          #emoriver = ./home/emoriver/t4801onnixos.nix;
        };
      };
    };

    mkNixos = name: cfg:
      lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgsUnstable; };
        modules = [
          cfg.hostModule
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit pkgsUnstable; };

              users = lib.mapAttrs (user: path: import path) cfg.users;

              backupFileExtension = "backup";
            };
          }
        ];
      };
  in
  {
    nixosConfigurations = lib.mapAttrs mkNixos hosts;
  };
}
