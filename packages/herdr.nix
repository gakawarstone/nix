{
  fetchurl,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "herdr";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/herdrdev/herdr/releases/download/v0.8.0/herdr-linux-x86_64";
    hash = "sha256-uHLqfkD6LLF+hXrJtisb8m23tAPGIvXS8/WzX26azSg=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/herdr"
    runHook postInstall
  '';

  meta = {
    description = "Terminal workspace manager for AI coding agents";
    homepage = "https://herdr.dev";
    license = lib.licenses.asl20;
    mainProgram = "herdr";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
