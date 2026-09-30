{ pkgs, ... }:

{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  environment.systemPackages = with pkgs; [
    gnupg
    pass
    github-cli
  ];

  environment.extraInit = ''
    export GPG_TTY=$(tty)
  '';
}
