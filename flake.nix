{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "git+https://github.com/gakawarstone/dotfiles?ref=master&shallow=1";
      flake = false;
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { dotfiles, home-manager, nixpkgs, nixpkgs-unstable, nur, ... }:
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
          home-manager.nixosModules.home-manager
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
