# Laptop dotfiles

The laptop deliberately uses an editable checkout at `~/dotfiles`. Nix pins the
Neovim configuration through the `nvim` flake input, but does not pin the separate
dotfiles checkout. A Nix rebuild does not fetch or update that checkout.

For user `gws`, clone it before starting the desktop:

```sh
git clone git@github.com:gakawarstone/dotfiles.git ~/dotfiles
```

If SSH authentication has not been restored yet, use the HTTPS URL instead:

```sh
git clone https://github.com/gakawarstone/dotfiles.git ~/dotfiles
```

Required paths used directly by this configuration:

| Path under `~/dotfiles` | Consumer |
| --- | --- |
| `configs/herdr/.config/herdr` | Home Manager symlink for the Herdr configuration |
| `bins/screen` | Personal `screen` screenshot wrapper |
| `bins/toggle_theme` | Personal `toggle_theme` wrapper |

`home/gws/dotfiles.nix` manages the Herdr link. `home/gws/desktop.nix` installs the
shell wrappers with their runtime dependencies. Changes to these dotfiles take
effect without rebuilding NixOS. Keep the checkout available at this location;
the Herdr link is otherwise dangling and the wrappers cannot run their scripts.

Other desktop configuration managed by the dotfiles repository must be installed
using that repository's setup instructions. This Nix repository only manages
the links and wrappers listed above. The VM does not depend on this checkout.
