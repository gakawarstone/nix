# Pinentry is configured system-wide by modules/pass.nix.
gpgconf --kill gpg-agent
export GPG_TTY=$(tty)
gpg --import private.asc
