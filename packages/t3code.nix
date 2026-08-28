{
  appimageTools,
  fetchurl,
  lib,
  makeDesktopItem,
}:

let
  pname = "t3code";
  version = "0.0.34-nightly.20260823.1164";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-ilCRf2u5cMXwx4elWujfXOWtS6D4ZORmrxkaIJGt+HY=";
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "t3code %U";
    desktopName = "T3 Code";
    comment = "AI code editor";
    icon = pname;
    terminal = false;
    mimeTypes = [ "x-scheme-handler/t3code" ];
    categories = [
      "Development"
      "IDE"
    ];
    startupNotify = false;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 "${desktopItem}/share/applications/t3code.desktop" \
      "$out/share/applications/t3code.desktop"
    install -Dm444 "${contents}/t3code.png" \
      "$out/share/icons/hicolor/512x512/apps/t3code.png"
  '';

  meta = {
    description = "AI code editor";
    homepage = "https://github.com/pingdotgg/t3code";
    mainProgram = "t3code";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
