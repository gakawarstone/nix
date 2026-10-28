# Stud.GK package source and setup

`stud-gk` is installed in the laptop's Home Manager packages and exposed as
`.#stud-gk` and `checks.x86_64-linux.stud-gk`. It wraps the Linux x86_64 AppImage;
it does not build the application from source during a Nix build.

## Pinned upstream artifact

The upstream repository, [gakawarstone/stud.gk](https://github.com/gakawarstone/stud.gk),
and its release asset are public. `fetchurl` downloads the exact AppImage and
verifies its SHA-256 automatically. No GitHub login or manual store import is
required on a clean machine.

| Field | Pinned value |
| --- | --- |
| Release | [`v1.0.0-build.17`](https://github.com/gakawarstone/stud.gk/releases/tag/v1.0.0-build.17) |
| Source commit | `c8b05a1258d4870e2b63ea80682680019feac2ec` |
| Asset | [`Stud.GK-1.0.0-build.17-linux-x86_64.AppImage`](https://github.com/gakawarstone/stud.gk/releases/download/v1.0.0-build.17/Stud.GK-1.0.0-build.17-linux-x86_64.AppImage) |
| Size | 169527557 bytes |
| SHA-256 (hex) | `cca7a3bb3724cecaf0858fc94a5d20b94c25debdd71539e0d03989301eeff72a` |
| SHA-256 (Nix SRI) | `sha256-zKejuzckzsrwhY/JSl0guUwl3r3XFTng0DmJMB7v9yo=` |

Build and check from this Nix checkout without activating anything:

```sh
nix build --no-link --no-update-lock-file .#stud-gk
make check
make check-build
```

`make check` evaluates derivations and checks formatting, while
`make check-build` also builds the local packages, including Stud.GK.
To exercise the source download even when the exact AppImage is already in
the local store, rebuild the fetcher:

```sh
nix build --rebuild --no-link --no-update-lock-file .#stud-gk.src
```

## Download diagnostics and release integrity

- A GitHub HTTP 404 means the public release URL or asset is unavailable.
  Check the pinned release and filename above; do not substitute the latest
  release or change the version merely to bypass the error.
- A checksum mismatch means the downloaded bytes differ from the pinned
  artifact. The pinned upstream
  [release workflow](https://github.com/gakawarstone/stud.gk/blob/c8b05a1258d4870e2b63ea80682680019feac2ec/.github/workflows/linux-release.yml)
  uses `--clobber`, so a rerun can replace an asset under the same tag.
  Investigate the changed bytes before updating the hash.
- Network errors require working HTTPS access from the Nix build machine to
  GitHub and its release asset storage. A cached successful package build alone
  does not verify that this download still works; use the fetcher rebuild above.

The source revision and version identify the release, but upstream does not
promise byte-for-byte reproducible AppImages. Its `package.json` contains
`1.0.0`; CI passes `--config.extraMetadata.version=1.0.0-build.17` to
`npm run dist:linux` for this release. A local rebuild with the same version
may have different bytes and cannot replace the pinned asset unless its
checksum matches.

## Desktop integration

The package installs `bin/stud-gk`, `share/applications/stud-gk.desktop`, and the
AppImage's 512x512 icon as `share/icons/hicolor/512x512/apps/stud-gk.png`.
`Name=Stud.GK`, `Icon=stud-gk`, category `Education`, and
`StartupWMClass=Stud.GK` match upstream's build configuration.
The desktop filename also matches upstream's `app.setDesktopName` call.
`Exec=stud-gk` opens the application's local UI. No URL/file field code or MIME
association is advertised because this version has no external URL/file handler.

The AppImage runs through Nixpkgs' `appimageTools.wrapType2`; it does not need a
separate system-wide AppImage installation. Package and flake checks verify the
build, not an interactive desktop session or a real Stud.IP login. Test menu
launch, icon display, and window grouping in the target desktop after deployment.
