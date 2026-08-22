{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

      commonModules = [
        ./modules/base.nix
        ./modules/packages.nix
        ./modules/development.nix
      ];

      mkHost = { hostModule, extraModules ? [ ] }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgsUnstable; };
        modules = commonModules ++ [ hostModule ] ++ extraModules;
      };
    in
    {
      packages.${system}.nixos-rebuild =
        nixpkgs.legacyPackages.${system}.nixos-rebuild;

      nixosConfigurations = {
        gklaptop = mkHost {
          hostModule = ./hosts/gklaptop;
          extraModules = [
            ./modules/dotfiles.nix
            ./modules/fonts.nix
            ./modules/pass.nix
            ./modules/desktop/hyprland.nix
          ];
        };

        vm = mkHost {
          hostModule = ./hosts/vm;
          extraModules = [ ./modules/desktop/gnome.nix ];
        };
      };
    };
}
