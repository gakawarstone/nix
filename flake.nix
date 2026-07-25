{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nur, ... }:
    let
      system = "x86_64-linux";
    in
    {
      packages.${system}.nixos-rebuild =
        nixpkgs.legacyPackages.${system}.nixos-rebuild;

      nixosConfigurations.vmnix = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nur.modules.nixos.default
          ./hosts/vmnix
        ];
      };
    };
}
