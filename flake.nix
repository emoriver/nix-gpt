{
  description = "NixOS + Home Manager multi-host compatto";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils, ... }:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";

    # pkgs stable
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # pkgs unstable (li passiamo ai moduli Home)
    pkgsUnstable = 
      import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
    };


    # tabella host → moduli
    hosts = {
      macpnixos = {
        hostModule = ./hosts/macpnixos;
        homeModule = ./home/emoriver/macpnixos.nix;
      };
      w541onnixos = {
        hostModule = ./hosts/w541onnixos;
        homeModule = ./home/emoriver/w541onnixos.nix;
      };
      nix-immich-70 = {
        hostModule = ./hosts/nix-immich-70;
        homeModule = ./home/emoriver/nix-immich-70.nix;
      };
    };

    mkNixos = name: cfg:
      lib.nixosSystem {
        inherit system;
        modules = [
          cfg.hostModule
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = { inherit pkgsUnstable; };
            home-manager.users.emoriver = import cfg.homeModule;
            home-manager.backupFileExtension = "backup";
          }
        ];
        # opzionale: se ti serve usare pkgs/pkgsUnstable anche nei moduli NixOS
        specialArgs = { inherit pkgsUnstable; };
      };
  in
  {
    # ⬇⬇⬇ Top-level, come si aspetta nixos-rebuild
    nixosConfigurations = lib.mapAttrs mkNixos hosts;

    # (opzionale) Se vuoi generare pacchetti multi‑arch con flake-utils:
    # packages = flake-utils.lib.eachDefaultSystem (system:
    #   let pkgsFor = import nixpkgs { inherit system; };
    #   in { default = pkgsFor.hello; }
    # ).packages;
  };
}