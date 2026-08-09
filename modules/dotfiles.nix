{ dotfiles, pkgs, ... }:

let
  configuredDotfiles = pkgs.runCommand "dotfiles-configured" { } ''
    cp -R ${dotfiles} "$out"
    chmod -R u+w "$out"
    cp ${../dotfiles/config.py} "$out/gkdots/config.py"
  '';

  dotfilesInstall = pkgs.writeShellApplication {
    name = "dotfiles-install";
    runtimeInputs = with pkgs; [
      gnumake
      python3
      stow
    ];
    text = ''
      cd ${configuredDotfiles}
      exec make install
    '';
  };
in
{
  environment.systemPackages = [ dotfilesInstall ];
}
