# HS Flensburg on gklaptop

`modules/hsflensburg.nix` groups the Git identities, GitLab HTTPS credential,
and eduroam configuration. The identities, GitLab token, and eduroam profile
come from encrypted files in `secrets/` during NixOS activation. No interactive
GitLab setup step is needed.

The encrypted `secrets/git-default-identity.cfg` becomes `~/.gitconfig` and
includes the encrypted HS Flensburg identity for repositories whose remote
points at `gitlab.hs-flensburg.de`. For HTTPS access, the credential helper
reads the decrypted `secrets/gitlab-hs-flensburg.json` from `/run/secrets/`.
Only `gws` can read these files; their contents are never embedded in the Nix
store. Git commits still record the selected author name and email.

To rotate the GitLab token, edit the encrypted file and rebuild:

```sh
nix shell nixpkgs#sops -c sops secrets/gitlab-hs-flensburg.json
sudo nixos-rebuild switch --flake .#gklaptop
```

The JSON file contains `username` and `token` fields. For GitLab personal
access tokens, `username` is `oauth2`. See [eduroam](eduroam.md) for Wi-Fi
credential updates and connection checks.
