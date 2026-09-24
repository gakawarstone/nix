{ config, lib, pkgs, ... }:

let
  user = "gws";
  home = "/home/${user}";

  lock = pkgs.writeShellApplication {
    name = "lock";
    runtimeInputs = [ pkgs.swaylock ];
    text = ''
      swaylock --daemonize --color 1e1e2e
    '';
  };

  screen = pkgs.writeShellApplication {
    name = "screen";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      grim
      slurp
      wl-clipboard
    ];
    text = ''
      exec ${pkgs.bash}/bin/bash "$HOME/dotfiles/bins/screen" "$@"
    '';
  };

  toggleTheme = pkgs.writeShellApplication {
    name = "toggle_theme";
    runtimeInputs = with pkgs; [ coreutils glib procps ];
    text = ''
      exec ${pkgs.bash}/bin/bash "$HOME/dotfiles/bins/toggle_theme" "$@"
    '';
  };

  quickshellWithEffects = pkgs.symlinkJoin {
    name = "quickshell-with-effects";
    paths = [ pkgs.quickshell ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/quickshell" \
        --prefix QML_IMPORT_PATH : "${pkgs.qt6.qt5compat}/lib/qt-6/qml"
      wrapProgram "$out/bin/qs" \
        --prefix QML_IMPORT_PATH : "${pkgs.qt6.qt5compat}/lib/qt-6/qml"
    '';
  };
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services = {
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        user = "greeter";
      };
    };

    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # powerOnBoot cannot enable a controller whose rfkill state was persisted as
  # blocked, so clear the software block before BlueZ starts.
  systemd.services.bluetooth-unblock = {
    description = "Unblock Bluetooth radio";
    requiredBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    systemPackages = with pkgs; [
      brightnessctl
      kdePackages.dolphin
      dunst
      foot
      grim
      hyprpaper
      libnotify
      networkmanagerapplet
      playerctl
      quickshellWithEffects
      screen
      slurp
      swaylock
      wl-clipboard
      wofi
      lock
      toggleTheme
    ] ++ lib.optionals (lib.hasAttr "legcord" pkgs) [ pkgs.legcord ]
      ++ lib.optionals (lib.hasAttr "thunderbird" pkgs) [ pkgs.thunderbird ];
  };

  systemd.tmpfiles.rules = [
    "d ${home}/.config 0755 ${user} users -"
    "d ${home}/Images 0755 ${user} users -"
  ];
}
