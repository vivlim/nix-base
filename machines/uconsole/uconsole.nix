# see https://github.com/vivlim/oom-hardware/blob/main/uconsole/default.nix

{ lib, pkgs, oom-hardware, ... }: let
  inherit (lib) mkDefault;
in 

{
    hardware.raspberry-pi."4" = {
      xhci.enable = mkDefault false;
      dwc2.enable = mkDefault true;
      dwc2.dr_mode = mkDefault "host";
      overlays = {
        cpu-revision.enable = mkDefault true;
        audremap.enable = mkDefault true;
        vc4-kms-v3d.enable = mkDefault true;
        cpi-disable-pcie.enable = mkDefault true;
        cpi-disable-genet.enable = mkDefault true;
        cpi-uconsole.enable = mkDefault true;
        cpi-i2c1.enable = mkDefault false;
        cpi-spi4.enable = mkDefault false;
        cpi-bluetooth.enable = mkDefault true;
      };
    };

    hardware.deviceTree = {
      enable = true;
      filter = "bcm2711-rpi-cm4.dtb";
      overlaysParams = [
        {
          name = "bcm2711-rpi-cm4";
          params = {
            ant2 = mkDefault "on";
            audio = mkDefault "on";
            spi = mkDefault "off";
            i2c_arm = mkDefault "on";
          };
        }
        {
          name = "cpu-revision";
          params = {cm4-8 = mkDefault "on";};
        }
        {
          name = "audremap";
          params = {pins_12_13 = mkDefault "on";};
        }
        {
          name = "vc4-kms-v3d";
          params = {
            cma-384 = mkDefault "on";
            # cma-512 = mkDefault "on";
            nohdmi1 = mkDefault "on";
          };
        }
      ];
    };

    users.groups.spi = {};
    services.udev.extraRules = ''
      SUBSYSTEM=="spidev", KERNEL=="spidev0.0", GROUP="spi", MODE="0660"
    '';
}
