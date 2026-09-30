{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings.oracle = {
      HostName = "168.138.69.45";
      User = "ubuntu";
      IdentityFile = "~/.ssh/ssh-key-2022-10-24.key";
      IdentitiesOnly = true;
    };
  };
}
