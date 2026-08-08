{ pkgs, pkgsUnstable, ... }:

let
  t3codeVersion = "0.0.32";

  t3code = pkgs.appimageTools.wrapType2 {
    pname = "t3code";
    version = t3codeVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/pingdotgg/t3code/releases/download/v${t3codeVersion}/T3-Code-${t3codeVersion}-x86_64.AppImage";
      hash = "sha256-SS7ctI7vlzCfNMS3CoEhuGfDronCBowuKLs5Oo2CLCI=";
    };
  };

  t3codeDesktop = pkgs.makeDesktopItem {
    name = "t3code";
    exec = "t3code %U";
    desktopName = "T3 Code";
    comment = "AI code editor";
    terminal = false;
    mimeTypes = [ "x-scheme-handler/t3code" ];
    categories = [ "Development" "IDE" ];
    startupNotify = false;
  };
in
{
  environment.systemPackages = with pkgs; [
    python314
    uv
    opencode
    pkgsUnstable.codex
    lazygit
    t3code
    t3codeDesktop
  ];
}
