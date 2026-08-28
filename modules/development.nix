{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python314
    uv
    opencode
    codex-bin
    herdr
    lazygit
    t3code
  ];
}
