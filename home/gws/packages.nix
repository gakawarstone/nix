{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      fastfetch
      helium
      telegram-desktop
      zed-editor
      starship
      zoxide
      yazi
      gkpager
      klartext
      chatgpt-linux
      tgsend
    ]
    ++ lib.optionals (lib.hasAttr "legcord" pkgs) [ pkgs.legcord ]
    ++ lib.optionals (lib.hasAttr "thunderbird" pkgs) [ pkgs.thunderbird ];
}
