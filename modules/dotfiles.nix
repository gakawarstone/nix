{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.dotfiles-install ];
}
