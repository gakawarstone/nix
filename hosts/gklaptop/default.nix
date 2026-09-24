{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/eduroam.nix
  ];

  networking.hostName = "gklaptop";
  networking.extraHosts = ''
    192.168.178.22 gkfeed.local
  '';

  # Keep rebuilds from saturating the laptop's 8 logical CPUs.
  nix.settings = {
    max-jobs = 2;
    cores = 2;
  };

  users.users.gws.shell = pkgs.fish;

  xdg.mime.defaultApplications = {
    "application/xhtml+xml" = "helium.desktop";
    "text/html" = "helium.desktop";
    "x-scheme-handler/http" = "helium.desktop";
    "x-scheme-handler/https" = "helium.desktop";
  };

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
