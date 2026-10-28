# Stud.GK package source and setup

`stud-gk` is installed in the laptop's Home Manager packages and exposed as
`.#stud-gk` and `checks.x86_64-linux.stud-gk`. It wraps the Linux x86_64 AppImage;
it does not build the application from source during a Nix build.

## Pinned upstream artifact

The upstream repository, [gakawarstone/studip](https://github.com/gakawarstone/studip),
is private. On 2026-10-28, authenticated GitHub API requests confirmed this
release and asset, while an anonymous request for the asset returned HTTP 404:

| Field | Pinned value |
| --- | --- |
| Release | [`v1.0.0-build.15`](https://github.com/gakawarstone/studip/releases/tag/v1.0.0-build.15) |
| Source commit | `91a8a5fd4700d0a1b240165bcaf70d29e812537e` |
| Asset | `Stud.GK-1.0.0-build.15-linux-x86_64.AppImage` |
| Size | 169515464 bytes |
| SHA-256 (hex) | `4c332be40fc8df0b5d63ba2dc88e1265b369387db0625171610a7e2ed883a6f9` |
| SHA-256 (Nix SRI) | `sha256-TDMr5A/I3wtdY7otyI4SZbNpOH2wYlFxYQp+LtiDpvk=` |

There is no anonymously accessible release asset, so the package uses
`requireFile` instead of `fetchurl`. A clean machine without a trusted binary
substitute needs this manual import before building Stud.GK, the laptop, or all
flake checks. `make check` only evaluates derivations and checks formatting; it
can pass without the AppImage. `make check-build` builds Stud.GK as well.

## Download, verify, and import

Use GitHub CLI with an account authorized to read the private repository
(`gh auth login` if needed). Run the following as the user who will run Nix,
on the machine that will perform the build:

```sh
mkdir -p ~/Downloads/stud-gk-1.0.0-build.15
cd ~/Downloads/stud-gk-1.0.0-build.15
gh release download v1.0.0-build.15 \
  --repo gakawarstone/studip \
  --pattern Stud.GK-1.0.0-build.15-linux-x86_64.AppImage
printf '%s  %s\n' \
  '4c332be40fc8df0b5d63ba2dc88e1265b369387db0625171610a7e2ed883a6f9' \
  'Stud.GK-1.0.0-build.15-linux-x86_64.AppImage' | sha256sum --check
```

Stop if verification fails. After it succeeds, import the file using the exact
basename above (the store name is part of the `requireFile` lookup):

```sh
nix-store --add-fixed sha256 ./Stud.GK-1.0.0-build.15-linux-x86_64.AppImage
```

For these bytes and this basename, the expected store path is:

```text
/nix/store/cr2xs13szlnkiz21r2xa00zajcvxrpg7-Stud.GK-1.0.0-build.15-linux-x86_64.AppImage
```

Return to this Nix checkout and build without activating anything:

```sh
nix build --no-link --no-update-lock-file .#stud-gk
make check
make check-build
```

GitHub credentials are used only by `gh`; they are not embedded in the Nix
derivation or passed to the Nix sandbox. An authorized owner can also supply an
existing copy of the exact AppImage; verify its checksum and import it in the
same way. Keep a copy outside the store if it must survive garbage collection.

## Building from the pinned source

If the release cannot be downloaded, obtain source access and check out the
exact commit. The commands below follow the pinned upstream
[`linux-release.yml`](https://github.com/gakawarstone/studip/blob/91a8a5fd4700d0a1b240165bcaf70d29e812537e/.github/workflows/linux-release.yml)
and [`electron-builder.json`](https://github.com/gakawarstone/studip/blob/91a8a5fd4700d0a1b240165bcaf70d29e812537e/electron-builder.json).
Use an Ubuntu 24.04 x86_64 build environment with Node.js 24, npm,
`libarchive-tools`, `libfuse2t64`, and `xvfb` installed, matching upstream CI.
Perform this separately from deploying the NixOS host:

```sh
gh repo clone gakawarstone/studip studip-build.15
cd studip-build.15
git checkout --detach 91a8a5fd4700d0a1b240165bcaf70d29e812537e
npm ci
npm test
npm run dist:linux -- --config.extraMetadata.version=1.0.0-build.15
CAMPUS_SMOKE_ENTRY="$PWD/release/linux-unpacked/resources/app.asar/electron/main.cjs" \
  xvfb-run -a npm run test:desktop -- --no-sandbox
```

The output must be `release/Stud.GK-1.0.0-build.15-linux-x86_64.AppImage`.
The explicit version override matters: `package.json` at this commit says
`1.0.0`; upstream CI appends `-build.15` using its workflow run number.

This reproduces the source revision and version, but upstream does not promise
a byte-for-byte reproducible AppImage. Build tool downloads, timestamps, or
environment differences can change the checksum. Verify the output against the
pinned hash before importing it. A different hash will not satisfy this package;
do not replace the hash or relabel a newer release to bypass verification.
If a rebuild differs, recover the original asset from an authorized owner or
backup. Without the original matching bytes or a trusted substitute, a clean
build of this pinned package remains unavailable.

## Clean-install diagnostics

- A GitHub 404 can mean missing authorization for this private repository.
  Check `gh auth status`, then `gh repo view gakawarstone/studip` and
  `gh release view v1.0.0-build.15 --repo gakawarstone/studip`. If repository
  access works but the release or asset is gone, request the original bytes
  from the owner rather than selecting the latest build.
- A `requireFile` failure means the exact source is missing from the build
  machine's store. Run `nix eval --raw .#stud-gk.src.outPath` in the Nix checkout
  to see the expected path, then `nix-store --check-validity <printed-path>`.
  Check the basename and checksum and repeat the import on that machine.
  A download on another host, or a differently named file, is insufficient.
- A checksum mismatch means the input is not the pinned asset, even if the
  filename matches. The upstream workflow uploads with `--clobber`, so a rerun
  can replace the asset under the same tag; the hash deliberately rejects
  different bytes. Preserve the original and investigate before changing the
  package.
- Successful evaluation or a build on an already populated store does not
  establish that a clean machine can download the source. Authenticated download
  and checksum verification are separate from the Nix build checks.

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
