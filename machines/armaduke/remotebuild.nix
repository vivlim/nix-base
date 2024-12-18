{ config, lib, pkgs, modulesPath, ... }:

{
  nix = {
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
    buildMachines = [{
      hostName = "cliffarmd.cow-bebop.ts.net";
      system = "aarch64-linux";
      protocol = "ssh-ng";
      maxJobs = 8;
      speedFactor = 2;
      sshUser = "vivlim";
      sshKey = "/home/vivlim/.ssh/id_ed25519";
      supportedFeatures = [ "kvm" "big-parallel" "nixos-test" ];
    }];
  };
  programs.ssh.knownHosts."cliffarmd.cow-bebop.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPl5/zeKGaOxQiF1A31XGpygVa1YBJWeZDRyzpcPI/3s";
}
