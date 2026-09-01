{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, sops-nix, ... }:
    let
      defaultSystem = "x86_64-linux";

      commonModules = [
        ./modules/base.nix
        ./modules/packages.nix
        ./modules/development.nix
      ];

      pkgs = import nixpkgs {
        system = defaultSystem;
        overlays = [ self.overlays.default ];
      };

      mkHost =
        {
          system ? defaultSystem,
          modules,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = [ self.overlays.default ];
            }
          ] ++ commonModules ++ modules;
        };
    in
    {
      overlays.default = import ./overlays;

      packages.${defaultSystem} = {
        inherit (pkgs) gkpager tgsend;
        nixos-rebuild = pkgs.nixos-rebuild;
      };

      nixosConfigurations = {
        gklaptop = mkHost {
          modules = [
            ./hosts/gklaptop
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            ./modules/wakatime.nix
            ./modules/dotfiles.nix
            ./modules/fonts.nix
            ./modules/pass.nix
            ./modules/desktop/hyprland.nix
          ];
        };

        vm = mkHost {
          modules = [
            ./hosts/vm
            ./modules/desktop/gnome.nix
          ];
        };
      };
    };
}
