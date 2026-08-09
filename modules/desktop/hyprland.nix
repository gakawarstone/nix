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
      quickshell
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
