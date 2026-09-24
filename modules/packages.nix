{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    fastfetch
    helium
    telegram-desktop
    zed-editor
    gnumake
    neovim
    bat
    btop
    starship
    zoxide
    yazi
    gkpager
    klartext
    chatgpt-linux
    tgsend
  ];
}
