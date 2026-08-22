{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

      tgsend = pkgs.callPackage ./packages/tgsend.nix { };

      commonModules = [
        ./modules/base.nix
        ./modules/packages.nix
        ./modules/development.nix
      ];

      mkHost = { hostModule, extraModules ? [ ] }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgsUnstable tgsend; };
        modules = commonModules ++ [ hostModule ] ++ extraModules;
      };
    in
    {
      packages.${system} = {
        nixos-rebuild = pkgs.nixos-rebuild;
        inherit tgsend;
      };

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
