{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    blueman.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Clear a persisted rfkill software block before BlueZ starts.
  systemd.services.bluetooth-unblock = {
    description = "Unblock Bluetooth radio";
    requiredBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };
}
