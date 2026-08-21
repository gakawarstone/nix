{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/packages.nix
    ../../modules/development.nix
    ../../modules/desktop/gnome.nix
  ];

  networking.hostName = "vm";

  # Keep this at the NixOS release used for the target's first installation.
  system.stateVersion = "26.05";
}
