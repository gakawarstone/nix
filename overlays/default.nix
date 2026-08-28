# Exposes the local derivations in ../packages as pkgs.<name>.
final: _:

{
  chatgpt-linux = final.callPackage ../packages/chatgpt-linux.nix { };
  codex-bin = final.callPackage ../packages/codex-bin.nix { };
  dotfiles-install = final.callPackage ../packages/dotfiles-install.nix { };
  gkpager = final.callPackage ../packages/gkpager.nix { };
  helium = final.callPackage ../packages/helium.nix { };
  helvetica-255 = final.callPackage ../packages/helvetica-255.nix { };
  herdr = final.callPackage ../packages/herdr.nix { };
  t3code = final.callPackage ../packages/t3code.nix { };
  tgsend = final.callPackage ../packages/tgsend.nix { };
}
