{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/packages.nix
    ../../modules/dotfiles.nix
    ../../modules/fonts.nix
    ../../modules/development.nix
    ../../modules/pass.nix
    ../../modules/desktop/hyprland.nix
  ];

  networking.hostName = "gklaptop";

  users.users.gws.shell = pkgs.fish;

  programs.ssh.extraConfig = ''
    Host oracle
      HostName 168.138.69.45
      User ubuntu
      IdentityFile ~/.ssh/ssh-key-2022-10-24.key
      IdentitiesOnly yes
  '';

  # Keep this at the NixOS release used for the target's first installation.
  system.stateVersion = "26.05";
}
