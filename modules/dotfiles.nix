{ lib, pkgs, ... }:

let
  dotfilesRepository = "https://github.com/gakawarstone/dotfiles.git";

  dotfilesInstall = pkgs.writeShellApplication {
    name = "dotfiles-install";
    runtimeInputs = with pkgs; [
      coreutils
      git
      gnumake
      python3
      stow
      uv
    ];
    text = ''
      dotfiles_dir="$HOME/dotfiles"

      if [ ! -e "$dotfiles_dir" ]; then
        echo "Cloning dotfiles into $dotfiles_dir"
        git clone ${lib.escapeShellArg dotfilesRepository} "$dotfiles_dir"
      elif [ ! -d "$dotfiles_dir/.git" ]; then
        echo "$dotfiles_dir exists but is not a Git checkout" >&2
        exit 1
      else
        echo "Updating dotfiles in $dotfiles_dir"
        git -C "$dotfiles_dir" pull --ff-only
      fi

      if [ ! -f "$dotfiles_dir/Makefile" ]; then
        echo "$dotfiles_dir does not provide an installer" >&2
        exit 1
      fi

      make -C "$dotfiles_dir" install
    '';
  };
in
{
  environment.systemPackages = [ dotfilesInstall ];
}
