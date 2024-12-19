# see https://github.com/vivlim/oom-hardware/blob/main/uconsole/default.nix

{ config, lib, pkgs, oom-hardware, ... }: 
{
  config.sdImage = {
    imageBaseName = "nixos-sd-uconsole";
    compressImage = false;
    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        [pi4]
        kernel=u-boot-rpi4.bin
        enable_gic=1
        armstub=armstub8-gic.bin

        [all]
        arm_64bit=1
        enable_uart=1
        avoid_warnings=1
        gpio=10=ip,np
        gpio=11=op
        arm_boost=1

        #over_voltage=6
        #arm_freq=2000
        #gpu_freq=750

        display_auto_detect=1
        ignore_lcd=1
        disable_fw_kms_setup=1
        disable_audio_dither=1
        pwm_sample_bits=20
      '';
    in ''
      echo "build dir: $NIX_BUILD_TOP"
      ls -lah $NIX_BUILD_TOP
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bootcode.bin $NIX_BUILD_TOP/firmware
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/fixup*.dat $NIX_BUILD_TOP/firmware
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/start*.elf $NIX_BUILD_TOP/firmware
      ls -lah $NIX_BUILD_TOP

      # Add the config
      cp ${configTxt} firmware/config.txt

      # Add pi4 specific files
      cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
      cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb firmware/
    '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      mkdir -p ./files/boot/firmware
      mkdir -p ./files/etc/nixos
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
