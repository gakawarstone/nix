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
    nur.repos.Ev357.helium
    telegram-desktop
    zed-editor
    gnumake
    neovim
    bat
    btop
    foot
    starship
    zoxide
  ];
}
