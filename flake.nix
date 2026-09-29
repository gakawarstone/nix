{
  description = "NixOS configuration with Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    nvim = {
      url = "github:gakawarstone/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, nvim, sops-nix, ... }:
    let
      defaultSystem = "x86_64-linux";

      commonModules = [
        ./modules/base.nix
        ./modules/packages.nix
        ./modules/development.nix
      ];

      pkgsUnstable = import nixpkgs-unstable {
        system = defaultSystem;
      };

      codexOverlay = _: _: {
        codex-bin = pkgsUnstable.callPackage ./packages/codex-bin.nix { };
      };

      pkgs = import nixpkgs {
        system = defaultSystem;
        overlays = [ self.overlays.default codexOverlay ];
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
              nixpkgs.overlays = [ self.overlays.default codexOverlay ];
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
            { home-manager.sharedModules = [ nvim.homeManagerModules.default ]; }
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
