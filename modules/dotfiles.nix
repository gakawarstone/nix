{ ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";

    users.gws = { config, pkgs, ... }: {
      home.stateVersion = "26.05";

      programs.gakawarstone-nvim = {
        enable = true;
        extraPackages = with pkgs; [
          elmPackages.elm
          elmPackages.elm-format
          elmPackages.elm-language-server
          gopls
          lua-language-server
          marksman
          nil
          nixfmt
          prettier
          pyright
          ruff
          rust-analyzer
          stylua
          tailwindcss-language-server
          typescript-language-server
        ];
      };

      home.file.".local/bin/nvim".source = pkgs.writeShellScript "gakawarstone-nvim" ''
        export PATH="${config.home.path}/bin:$PATH"
        exec "${config.home.path}/bin/nvim" "$@"
      '';

      xdg.configFile."herdr".source =
        config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/configs/herdr/.config/herdr";
    };
  };
}
