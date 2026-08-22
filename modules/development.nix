{ pkgs, pkgsUnstable, ... }:

let
  herdr = pkgs.callPackage ../packages/herdr.nix { };
  t3code = pkgs.callPackage ../packages/t3code.nix { };
in
{
  environment.systemPackages = with pkgs; [
    python314
    uv
    pkgsUnstable.opencode
    pkgsUnstable.codex
    herdr
    lazygit
    t3code
  ];
}
