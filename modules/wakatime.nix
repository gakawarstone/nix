{ ... }:

{
  sops.secrets.wakatime = {
    sopsFile = ../secrets/wakatime.cfg;
    format = "binary";
    path = "/home/gws/.wakatime.cfg";
    owner = "gws";
    group = "users";
    mode = "0600";
  };
}
