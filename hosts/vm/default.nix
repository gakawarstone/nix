{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "vm";

  # Keep this at the NixOS release used for the target's first installation.
  system.stateVersion = "26.05";
}
