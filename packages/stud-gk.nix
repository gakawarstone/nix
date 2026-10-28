{
  appimageTools,
  lib,
  makeDesktopItem,
  requireFile,
}:

let
  pname = "stud-gk";
  version = "1.0.0-build.15";

  # Upstream and its releases are private; fetchurl cannot download anonymously.
  src = requireFile {
    name = "Stud.GK-${version}-linux-x86_64.AppImage";
    hash = "sha256-TDMr5A/I3wtdY7otyI4SZbNpOH2wYlFxYQp+LtiDpvk=";
    message = ''
      Stud.GK ${version} requires access to the private gakawarstone/studip repository.
      Download the pinned release asset with an authorized GitHub CLI session:
        gh release download v${version} --repo gakawarstone/studip --pattern Stud.GK-${version}-linux-x86_64.AppImage
      Verify its SHA-256 is sha256-TDMr5A/I3wtdY7otyI4SZbNpOH2wYlFxYQp+LtiDpvk=,
      then import it from the download directory:
        nix-store --add-fixed sha256 ./Stud.GK-${version}-linux-x86_64.AppImage
      See docs/stud-gk.md for verification, source build instructions, and clean-install diagnostics.
    '';
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    # Upstream opens its own local UI and has no URL/file argument handler.
    exec = pname;
    desktopName = "Stud.GK";
    comment = "Local read-only Stud.IP companion";
    icon = pname;
    categories = [ "Education" ];
    startupWMClass = "Stud.GK";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 "${desktopItem}/share/applications/${pname}.desktop" \
      "$out/share/applications/${pname}.desktop"
    install -Dm444 "${contents}/usr/share/icons/hicolor/512x512/apps/${pname}.png" \
      "$out/share/icons/hicolor/512x512/apps/${pname}.png"
  '';

  meta = {
    description = "Local read-only Stud.IP companion";
    homepage = "https://github.com/gakawarstone/studip";
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
