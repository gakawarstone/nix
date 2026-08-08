mkdir -p ~/.gnupg
echo "pinentry-program /run/current-system/sw/bin/pinentry" >> ~/.gnupg/gpg-agent.conf

gpgconf --kill gpg-agent
export GPG_TTY=$(tty)
gpg --import private.asc
