{ ... }:

{
  sops.secrets.tgsend = {
    sopsFile = ../secrets/tgsend.cfg;
    format = "binary";
    path = "/home/gws/.config/tgsend/.env";
    owner = "gws";
    group = "users";
    mode = "0600";
  };
}
