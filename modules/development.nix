{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python314
    uv
    typst
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-language-server
    jetbrains.idea
    opencode
    codex-bin
    herdr
    lazygit
    t3code
  ];
}
