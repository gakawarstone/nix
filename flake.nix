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
  };

  outputs = { dotfiles, home-manager, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

      mkHost = { hostModule, extraModules ? [ ], extraSpecialArgs ? { } }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgsUnstable; } // extraSpecialArgs;
          modules = extraModules ++ [ hostModule ];
        };
    in
    {
      packages.${system}.nixos-rebuild =
        nixpkgs.legacyPackages.${system}.nixos-rebuild;

      nixosConfigurations = {
        gklaptop = mkHost {
          hostModule = ./hosts/gklaptop;
          extraModules = [ home-manager.nixosModules.home-manager ];
          extraSpecialArgs = { inherit dotfiles; };
        };
        vm = mkHost { hostModule = ./hosts/vm; };
      };
    };
}
