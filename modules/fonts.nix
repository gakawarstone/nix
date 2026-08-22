{ pkgs, ... }:

let
  helvetica255 = pkgs.callPackage ../packages/helvetica-255.nix { };
in
{
  fonts.packages = with pkgs; [
    nerd-fonts.monaspace
    font-awesome
    helvetica255
  ];
}
