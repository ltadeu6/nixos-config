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
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-openclaw.url = "github:openclaw/nix-openclaw";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, zen-browser, nix-openclaw, ... }:
    let
      system = "x86_64-linux";
      enableOpenClaw = false;
    in {
      nixosConfigurations.Nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit agenix zen-browser; };
        modules = [
          ./hosts/Nixos/configuration.nix
          agenix.nixosModules.default
          {
            nixpkgs.overlays = [
              nix-openclaw.overlays.default
              (final: prev: {
                openclaw = prev.openclaw.overrideAttrs (_: {
                  OPENCLAW_DISABLE_BUNDLED_PLUGIN_POSTINSTALL = "1";
                });
                "openclaw-gateway" = prev."openclaw-gateway".overrideAttrs (_: {
                  OPENCLAW_DISABLE_BUNDLED_PLUGIN_POSTINSTALL = "1";
                });
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
              imports =
                [
                  ./home/ltadeu6.nix
                ]
                ++ nixpkgs.lib.optionals enableOpenClaw [
                  nix-openclaw.homeManagerModules.openclaw
                  ./home/openclaw.nix
                ];
            };
          }
        ];
      };
    };
}
