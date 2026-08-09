{ pkgs, ... }:

let
  helvetica255 = pkgs.stdenvNoCC.mkDerivation {
    pname = "helvetica-255";
    version = "1.0";

    src = pkgs.fetchzip {
      url = "https://font.download/dl/font/helvetica-255.zip";
      hash = "sha256-J5efRtnF9O8V7ARZf5pG8Kj70NIpLnYzSWty1JedF3k=";
      stripRoot = false;
    };

    installPhase = ''
      runHook preInstall

      install -d $out/share/fonts/truetype
      install -m 0444 -t $out/share/fonts/truetype -- *.otf *.ttf

      runHook postInstall
    '';
  };
in
{
  fonts.packages = with pkgs; [
    nerd-fonts.monaspace
    font-awesome
    helvetica255
  ];
}
