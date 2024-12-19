# see https://github.com/vivlim/oom-hardware/blob/main/uconsole/default.nix

{ lib, pkgs, oom-hardware, ... }: let
  inherit (lib) mkDefault;
in 
{
  boot.supportedFilesystems.zfs = lib.mkForce false;
  boot.consoleLogLevel = lib.mkDefault 7;
  console = {
    earlySetup = true;
    font = "ter-v32n";
    packages = with pkgs; [terminus_font];
  };
  boot.kernelParams = [
    "8250.nr_uarts=1"
    "vc_mem.mem_base=0x3ec00000"
    "vc_mem.mem_size=0x20000000"
    "console=ttyS0,115200"
    "console=tty1"
    "plymouth.ignore-serial-consoles"
    "snd_bcm2835.enable_hdmi=1"
    "snd_bcm2835.enable_headphones=1"
    "psi=1"
    "iommu=force"
    "iomem=relaxed"
    "swiotlb=131072"
  ];

    # Exclude more stuff from kernel
    boot.kernelPatches = [
      {
        name = "remove-unneeded-stuff";
        patch = null;
        extraStructuredConfig = with lib; {
          DRM_AMDGPU = kernel.no;
          DRM_AMDGPU_CIK = mkForce (kernel.option kernel.no);
          DRM_AMDGPU_SI = mkForce (kernel.option kernel.no);
          DRM_AMDGPU_USERPTR = mkForce (kernel.option kernel.no);
          DRM_AMD_DC_FP = mkForce (kernel.option kernel.no);
          DRM_AMD_DC_SI = mkForce (kernel.option kernel.no);
          HSA_AMD = mkForce (kernel.option kernel.no);
          DRM_NOUVEAU = kernel.no;
          DRM_RADEON = kernel.no;
          DRM_GMA500 = mkForce kernel.no;
          FIREWIRE = kernel.no;
        };
      }
    ];

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
