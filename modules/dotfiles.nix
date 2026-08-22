{ pkgs, ... }:

let
  dotfilesInstall = pkgs.callPackage ../packages/dotfiles-install.nix { };
in
{
  environment.systemPackages = [ dotfilesInstall ];
}
