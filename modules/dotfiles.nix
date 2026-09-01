{ ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";

    users.gws = { config, ... }: {
      home.stateVersion = "26.05";

      xdg.configFile."herdr".source =
        config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/configs/herdr/.config/herdr";
    };
  };
}
