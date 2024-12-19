# see https://github.com/vivlim/oom-hardware/blob/main/uconsole/default.nix

{ config, lib, pkgs, oom-hardware, modulesPath, ... }: 
{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-uuid/2178-694E";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022" "nofail" "noauto"];
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
}
