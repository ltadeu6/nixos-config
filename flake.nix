{
  description = "NixOS configuration with flakes + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, nix-openclaw, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.Nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit agenix; };
        modules = [
          ./hosts/Nixos/configuration.nix
          agenix.nixosModules.default
          {
            nixpkgs.overlays = [
              nix-openclaw.overlays.default
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config = prev.config;
                };
              })
            ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users.ltadeu6 = {
              imports = [
                nix-openclaw.homeManagerModules.openclaw
                ./home/ltadeu6.nix
              ];
            };
          }
        ];
      };
    };
}
