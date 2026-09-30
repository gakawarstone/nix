# Personal NixOS configuration

Flake-based NixOS configurations for an x86_64 laptop and a GNOME VM, with
Home Manager, encrypted secrets, and local packages.

## Hosts

| Host | Profile | Desktop | Personal configuration |
| --- | --- | --- | --- |
| `gklaptop` | Workstation | Hyprland | `gws` Home Manager, development tools, SOPS secrets, eduroam |
| `vm` | Minimal | GNOME | Basic `gws` account, Vim, no personal secrets or development apps |

The VM hardware configuration is a placeholder for evaluation. Replace it with
the target's generated configuration before deployment. `make build`, `make test`,
and `make switch` reject the placeholder.

## Layout

```text
flake.nix          Inputs, overlays, host creation, packages, and checks
hosts/<host>/      Host imports, generated hardware, and host-specific settings
profiles/          Shared minimal and workstation configurations
modules/system/    System defaults, basic tools, fonts, and SOPS integration
modules/services/  Audio, eduroam, and GnuPG services
modules/desktop/   Desktop sessions and their system requirements
home/gws/          Personal apps, editor, Git, SSH, dotfiles, and secret destinations
packages/          Local derivations; gkpager owns its adjacent Cargo.lock
overlays/          Local packages and selected tools from unstable nixpkgs
checks/            Formatting, host evaluation, and local package build checks
scripts/           Credential maintenance helpers
secrets/           SOPS-encrypted files
docs/              Feature setup and maintenance guides
```

Hosts choose their profiles and features in `hosts/<host>/default.nix`. The
workstation profile adds fonts, audio, and support for unfree packages to the
minimal profile. Personal apps are installed through Home Manager for `gws`.
`home/gws/nixos.nix` connects that user configuration to NixOS and imports its
Home Manager and SOPS dependencies.

## Setup

Start from an installed NixOS system with the `nix-command` and `flakes`
experimental features enabled. Clone this repository, then enter its tool shell:

```sh
cd ~/nix
nix develop
```

1. Copy the target's generated hardware configuration into
   `hosts/<host>/hardware-configuration.nix`. Generate it on the target with
   `sudo nixos-generate-config` if needed. Check the host's bootloader settings
   against its actual installation; the current hosts use UEFI/systemd-boot.
2. For the laptop, restore the personal age key for editing secrets and provision
   the host key as described in [SOPS setup](docs/sops.md). The laptop expects the
   SSH host key corresponding to the recipient in `.sops.yaml`. A reinstall with
   a new host key requires adding that recipient and updating the encrypted files.
3. Set up the laptop's separate dotfiles checkout using
   [the dotfiles guide](docs/dotfiles.md). Restore personal SSH and GPG keys as
   needed; they are not part of this repository.
4. Stage newly added or moved project files before using Git-backed flake commands:
   `git add <paths>`. The flake only includes files known to Git. Stage encrypted
   secret files, never plaintext keys or credentials.
5. Run `make check`, build the chosen host, and apply it:

```sh
make build CONFIGURATION=gklaptop
make test CONFIGURATION=gklaptop
make switch CONFIGURATION=gklaptop
```

`test` activates the configuration for the running system. `switch` also makes
it the boot default. Neither command sets an account password; provision that
separately on a fresh installation. If the initial installation requires writing
the bootloader, explicitly use `sudo nixos-rebuild switch --install-bootloader
--flake .#gklaptop`.

## Maintenance

| Command | Purpose |
| --- | --- |
| `make fmt` | Format Nix files |
| `make fmt-check` | Check formatting without changing files |
| `make check` | Check formatting and fully evaluate both host derivations and flake outputs |
| `make check-build` | Build the formatting, host evaluation, and nine local package checks |
| `make update` | Update `flake.lock` without activating the system |
| `make build CONFIGURATION=<host>` | Build a host without activating it; creates `result` |
| `make test CONFIGURATION=<host>` | Activate a host for the running system |
| `make switch CONFIGURATION=<host>` | Activate a host and update its boot default |
| `make clean` | Delete old generations and optimize the Nix store |

The default host is `gklaptop`. After `make update`, review the lockfile change,
run `make check`, then build and apply the selected host. Evaluation does not
verify that downloads or compilation succeed; use `make check-build` for local
packages or `make build` for the full host. Package checks do not boot either host.

All local packages are exposed as flake outputs, for example:

```sh
nix build .#gkpager
nix build .#helium
nix build .#codex-bin
```

`codex-bin` uses the local binary derivation with dependencies from unstable
nixpkgs; `opencode` comes directly from unstable. These choices are defined once
in `overlays/default.nix`. Other local packages use stable nixpkgs.

Feature guides: [dotfiles](docs/dotfiles.md), [SOPS](docs/sops.md),
[HS Flensburg Git](docs/hsflensburg.md), [eduroam](docs/eduroam.md),
[SSH](docs/ssh.md), and [password store](docs/pass.md).
