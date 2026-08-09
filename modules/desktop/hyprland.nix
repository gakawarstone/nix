{ config, dotfiles, lib, pkgs, ... }:

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
    text = builtins.readFile "${dotfiles}/bins/screen";
  };

  toggleTheme = pkgs.writeShellApplication {
    name = "toggle_theme";
    runtimeInputs = with pkgs; [ coreutils glib procps ];
    text = builtins.replaceStrings
      [
        ''DOTFILES="$HOME/dotfiles"''
        ''HYPR_DIR="$DOTFILES/configs/hyprland/.config/hypr"''
        ''FOOT_DIR="$DOTFILES/configs/foot/.config/foot"''
        ''QUICKSHELL_DIR="$DOTFILES/configs/quickshell/.config/quickshell"''
      ]
      [
        ""
        ''HYPR_DIR="$HOME/.config/hypr"''
        ''FOOT_DIR="$HOME/.config/foot"''
        ''QUICKSHELL_DIR="$HOME/.config/quickshell"''
      ]
      (builtins.readFile "${dotfiles}/bins/toggle_theme");
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

  # Keep the upstream files mutable so the adapted theme switcher can replace
  # their theme symlinks. Rebuilding restores the pinned upstream revision.
  system.activationScripts.gklaptopHyprlandDotfiles = {
    deps = [ "users" ];
    text = ''
      install -d -m 0755 -o ${user} -g users \
        ${home}/.config/hypr \
        ${home}/.config/quickshell \
        ${home}/.config/wofi \
        ${home}/.config/foot \
        ${home}/Images

      copy_config() {
        source_dir="$1"
        target_dir="$2"
        cp -R --remove-destination --no-preserve=mode,ownership \
          "$source_dir/." "$target_dir/"
        chown -R ${user}:users "$target_dir"
        chmod -R u+w "$target_dir"
      }

      copy_config ${dotfiles}/configs/hyprland/.config/hypr ${home}/.config/hypr
      copy_config ${dotfiles}/configs/quickshell/.config/quickshell ${home}/.config/quickshell
      copy_config ${dotfiles}/configs/wofi/.config/wofi ${home}/.config/wofi
      copy_config ${dotfiles}/configs/foot/.config/foot ${home}/.config/foot

      cp ${home}/.config/foot/foot.j2.ini ${home}/.config/foot/foot.ini
      ${pkgs.gnused}/bin/sed -i 's/{{font_size}}/11/g' ${home}/.config/foot/foot.ini
      ln -sfn mocha.ini ${home}/.config/foot/theme.ini

      # The upstream setup is primarily docked. This catch-all keeps the
      # internal laptop panel and any unlisted output usable as well.
      ${pkgs.gnused}/bin/sed -i '1ihl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })' \
        ${home}/.config/hypr/hyprland.lua
      ${pkgs.gnused}/bin/sed -i 's#/home/gws/dotfiles/wallpapers#${dotfiles}/wallpapers#g' \
        ${home}/.config/hypr/latte_hyprpaper.conf \
        ${home}/.config/hypr/mocha_hyprpaper.conf

      chown -hR ${user}:users \
        ${home}/.config/hypr \
        ${home}/.config/quickshell \
        ${home}/.config/wofi \
        ${home}/.config/foot
    '';
  };

  systemd.tmpfiles.rules = [
    "d ${home}/.config 0755 ${user} users -"
    "d ${home}/Images 0755 ${user} users -"
  ];
}
