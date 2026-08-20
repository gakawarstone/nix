{ dotfiles, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.gws = {
      home.stateVersion = "26.05";

      xdg.configFile = {
        "alacritty".source = "${dotfiles}/configs/alacritty/.config/alacritty";
        "bat".source = "${dotfiles}/configs/bat/.config/bat";
        "dunst".source = "${dotfiles}/configs/dunst/.config/dunst";
        "fish".source = "${dotfiles}/configs/fish/.config/fish";
        "foot".source = "${dotfiles}/configs/foot/.config/foot";
        "quickshell".source = "${dotfiles}/configs/quickshell/.config/quickshell";
        "tmux".source = "${dotfiles}/configs/tmux/.config/tmux";
      };
    };
  };
}
