{
  description = "Hosting infra cluster";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    musnix = { url = "github:musnix/musnix"; };

    nur.url = "github:nix-community/NUR";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs,
              nixpkgs-stable,
              nixpkgs-unstable,
              nur,
              musnix,
              disko,
              ... }:
    let
      system = "x86_64-linux";

      nixosCustomSystem = { modules }: nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = rec {
          inherit nixpkgs-stable nixpkgs-unstable musnix disko;
          pkgs-stable = nixpkgs-stable.legacyPackages.${system};
          pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

          globalPath = ./global;

          nur-modules = import nur {
            nurpkgs = nixpkgs.legacyPackages.x86_64-linux;
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          };
        };

        modules = modules ++ [
          ./global/global.nix

          musnix.nixosModules.musnix
          nur.nixosModules.nur
          disko.nixosModules.disko
        ];
      };
    in
      {
        nixosConfigurations = {
          baphomet = nixosCustomSystem {
            modules = [
              ./nodes/baphomet/hardware-configuration.nix
              ./nodes/baphomet/disko-config.nix
              ./nodes/baphomet/configuration.nix
            ];
          };
        };
      };
}
