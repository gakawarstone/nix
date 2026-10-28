{
  pkgs,
  source,
  packages,
  hosts,
}:
let
  desktop = hosts.gklaptop.config.home-manager.users.gws;
  activitywatchUnits = pkgs.linkFarm "activitywatch-user-units" (
    map
      (name: {
        inherit name;
        path = desktop.xdg.configFile."systemd/user/${name}".source;
      })
      [
        "activitywatch.service"
        "activitywatch.target"
        "awatcher.service"
        "activitywatch.target.wants/activitywatch.service"
        "default.target.wants/activitywatch.target"
        "graphical-session.target.wants/awatcher.service"
      ]
  );
in
packages
// {
  # Verify ordering against the pinned HM ActivityWatch target and UWSM,
  # including the default.target transaction, rather than awatcher in isolation.
  activitywatch-units =
    pkgs.runCommand "activitywatch-units"
      {
        nativeBuildInputs = [ pkgs.systemd ];
      }
      ''
        export XDG_RUNTIME_DIR="$TMPDIR/runtime"
        mkdir -m 700 "$XDG_RUNTIME_DIR"
        export SYSTEMD_UNIT_PATH="${activitywatchUnits}:${hosts.gklaptop.pkgs.uwsm}/share/systemd/user:${pkgs.systemd}/example/systemd/user"
        systemd-analyze --user --man=no --generators=no verify \
          default.target awatcher.service wayland-session@hyprland.desktop.target
        touch "$out"
      '';

  # Force the complete derivations: checking their type alone can miss lazy
  # option conflicts in generated configuration files.
  host-evaluation = builtins.deepSeq (builtins.mapAttrs (
    _: host: host.config.system.build.toplevel.drvPath
  ) hosts) (pkgs.runCommand "host-evaluation" { } ''touch "$out"'');

  formatting =
    pkgs.runCommand "nix-formatting"
      {
        nativeBuildInputs = [
          pkgs.nixfmt
          pkgs.ripgrep
          pkgs.findutils
        ];
      }
      ''
        cd ${source}
        rg --files --hidden -g '*.nix' -g '!.git/**' -0 | xargs -0 -r nixfmt --check
        touch "$out"
      '';
}
