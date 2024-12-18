{ config, lib, pkgs, modulesPath, ... }:

{
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.buildMachines = [{
    hostName = "cliffarmd";
    system = "aarch64-linux";
    protocol = "ssh-ng";
    maxJobs = 8;
    speedFactor = 10;
    sshUser = "vivlim";
    sshKey = "/home/vivlim/.ssh/id_ed25519";
    supportedFeatures = [ "kvm" "big-parallel" ];
  }];
}
