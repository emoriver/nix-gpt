{
  description = "NixOS + Home Manager multi-host multi-user";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, impermanence, flake-utils, ... }:
  let
    lib = nixpkgs.lib;

    # pkgsUnstable ora è una funzione che accetta system
    # così ogni host ottiene i pacchetti compilati per la sua architettura
    mkPkgsUnstable = system: import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    hosts = {
      macpnixos = {
        system     = "x86_64-linux";
        hostModule = ./hosts/macpnixos;
        users = {
          emoriver = ./home/emoriver/macpnixos.nix;
        };
      };
      nix-immich-70 = {
        system     = "x86_64-linux";
        hostModule = ./hosts/nix-immich-70;
        users = {
          emoriver = ./home/emoriver/nix-immich-70.nix;
        };
      };
      w541onnixos = {
        system     = "x86_64-linux";
        hostModule = ./hosts/w541onnixos;
        users = {
          emoriver = ./home/emoriver/w541onnixos.nix;
        };
      };
      t4801onnixos = {
        system     = "x86_64-linux";
        hostModule = ./hosts/t4801onnixos;
        users = {
          carpinera = ./home/carpinera/t4801onnixos.nix;
        };
      };
      nixerrypie = {
        system     = "aarch64-linux";
        #impermanence = true;
        hostModule = ./hosts/nixerrypie;
        users = {
          emoriver = ./home/emoriver/nixerrypie.nix;
        };
      };
    };

    mkNixos = name: cfg:
    let
      system        = cfg.system;
      pkgsUnstable  = mkPkgsUnstable system;

      #extraModules  = if name == "nixerrypie"
      #                then [ impermanence.nixosModules.impermanence ]
      #                else [];
    in
      lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgsUnstable; };
        modules = extraModules ++ [
          cfg.hostModule
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs    = true;
              useUserPackages  = true;
              extraSpecialArgs = { inherit pkgsUnstable; };
              users            = lib.mapAttrs (user: path: import path) cfg.users;
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