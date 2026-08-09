{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    dotfiles = {
      url = "github:gakawarstone/dotfiles/adf7eea0053c18ef04993db58da767cc86ab7ea0";
      flake = false;
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nur, dotfiles, ... }:
    let
      system = "x86_64-linux";
    in
    {
      packages.${system}.nixos-rebuild =
        nixpkgs.legacyPackages.${system}.nixos-rebuild;

      nixosConfigurations.gklaptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit dotfiles;
          pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
        };
        modules = [
          nur.modules.nixos.default
          ./hosts/gklaptop
        ];
      };

      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs.pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
        modules = [
          nur.modules.nixos.default
          ./hosts/vm
        ];
      };
    };
}
