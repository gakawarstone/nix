{ lib, pkgs, ... }:

let
  dotfilesRepository = "https://github.com/gakawarstone/dotfiles.git";

  managedConfigs = [
    { package = "tmux"; target = ".config/tmux"; }
    { package = "alacritty"; target = ".config/alacritty"; }
    { package = "bat"; target = ".config/bat"; }
    { package = "dunst"; target = ".config/dunst"; }
    { package = "fish"; target = ".config/fish"; }
    { package = "quickshell"; target = ".config/quickshell"; }
    { package = "foot"; target = ".config/foot"; }
    { package = "hyprland"; target = ".config/hypr"; }
    { package = "wofi"; target = ".config/wofi"; }
  ];

  configSpecs = lib.concatMapStringsSep "\n" ({ package, target }:
    ''${package}:${target}'') managedConfigs;

  dotfilesInstall = pkgs.writeShellApplication {
    name = "dotfiles-install";
    runtimeInputs = with pkgs; [
      coreutils
      git
      gnused
      stow
    ];
    text = ''
      dotfiles_dir="$HOME/dotfiles"
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-install"

      if [ ! -e "$dotfiles_dir" ]; then
        echo "Cloning dotfiles into $dotfiles_dir"
        git clone ${lib.escapeShellArg dotfilesRepository} "$dotfiles_dir"
      elif [ ! -d "$dotfiles_dir/.git" ]; then
        echo "$dotfiles_dir exists but is not a Git checkout" >&2
        exit 1
      fi

      if [ ! -d "$dotfiles_dir/configs" ]; then
        echo "$dotfiles_dir does not contain a configs directory" >&2
        exit 1
      fi

      install -d "$state_dir/migrated"
      backup_dir="$state_dir/backups/$(date --utc +%Y%m%dT%H%M%SZ)"

      migrate_target() {
        package="$1"
        relative_target="$2"
        marker="$state_dir/migrated/$package"
        target="$HOME/$relative_target"

        if [ ! -e "$marker" ]; then
          if [ -e "$target" ] || [ -L "$target" ]; then
            backup_target="$backup_dir/$relative_target"
            install -d "$(dirname "$backup_target")"
            mv "$target" "$backup_target"
            echo "Backed up $target to $backup_target"
          fi
        fi

        stow_args=(
          --dir="$dotfiles_dir/configs"
          --target="$HOME"
          --no-folding
          --restow
        )

        stow "''${stow_args[@]}" "$package"
        touch "$marker"
      }

      while IFS=: read -r package relative_target; do
        migrate_target "$package" "$relative_target"
      done <<'CONFIGS'
      ${configSpecs}
      CONFIGS

      # foot.ini is generated and intentionally remains outside the Git checkout.
      sed 's/{{font_size}}/11/g' \
        "$dotfiles_dir/configs/foot/.config/foot/foot.j2.ini" \
        > "$HOME/.config/foot/foot.ini"
      ln -sfn mocha.ini "$HOME/.config/foot/theme.ini"

      echo "Dotfiles are linked from $dotfiles_dir"
    '';
  };
in
{
  environment.systemPackages = [ dotfilesInstall ];
}
