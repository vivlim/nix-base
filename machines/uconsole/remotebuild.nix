{ config, lib, pkgs, modulesPath, ... }:

{
  nix = {
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
    buildMachines = [
    {
      hostName = "armaduke.cow-bebop.ts.net";
      system = "aarch64-linux";
      protocol = "ssh-ng";
      maxJobs = 4;
      speedFactor = 1;
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/id_ed25519_build";
      #supportedFeatures = [ "kvm" "big-parallel" "nixos-test" ];
      supportedFeatures = [ "kvm" "big-parallel"];
      mandatoryFeatures = [ ];
    }
#    {
#      hostName = "cliffarmd.cow-bebop.ts.net";
#      system = "aarch64-linux";
#      protocol = "ssh-ng";
#      maxJobs = 8;
#      speedFactor = 2;
#      sshUser = "remotebuild";
#      sshKey = "/root/.ssh/id_ed25519_build";
#      #supportedFeatures = [ "kvm" "big-parallel" "nixos-test" ];
#      supportedFeatures = [ "big-parallel" ];
#      mandatoryFeatures = [ ];
#    }
    ];
  };
  programs.ssh.knownHosts."cliffarmd.cow-bebop.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPl5/zeKGaOxQiF1A31XGpygVa1YBJWeZDRyzpcPI/3s";
  programs.ssh.knownHosts."aarchduke.cow-bebop.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyI0zf9tRkU5iSYvV4h5rmdhvfXhItZNaJDkceajETu";
}
