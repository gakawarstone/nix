# Exposes the local derivations in ../packages as pkgs.<name>.
{ inputs }:
final: _:
let
  unstable = import inputs.nixpkgs-unstable {
    system = final.stdenv.hostPlatform.system;
  };
in
{
  chatgpt-linux = final.callPackage ../packages/chatgpt-linux.nix { };
  codex-bin = unstable.callPackage ../packages/codex-bin.nix { };
  opencode = unstable.opencode;
  gkpager = final.callPackage ../packages/gkpager { };
  helium = final.callPackage ../packages/helium.nix { };
  helvetica-255 = final.callPackage ../packages/helvetica-255.nix { };
  herdr = final.callPackage ../packages/herdr.nix { };
  klartext = final.callPackage ../packages/klartext.nix { };
  t3code = final.callPackage ../packages/t3code.nix { };
  tgsend = final.callPackage ../packages/tgsend.nix { };
}
