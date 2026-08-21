{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nur, ... }:
    let
      system = "x86_64-linux";
      pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

      mkHost = hostModule: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgsUnstable; };
        modules = [
          nur.modules.nixos.default
          hostModule
        ];
      };
    in
    {
      packages.${system}.nixos-rebuild =
        nixpkgs.legacyPackages.${system}.nixos-rebuild;

      nixosConfigurations = {
        gklaptop = mkHost ./hosts/gklaptop;
        vm = mkHost ./hosts/vm;
      };
    };
}
