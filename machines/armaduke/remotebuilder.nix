{ config, lib, pkgs, modulesPath, ... }:

{

  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAWppcEF0+3mksXcfAgQGDktzYXTc4OkDzmvYdOn14Il root@aarchduke"
    ];
  };

  users.groups.remotebuild = {};
  nix.settings.trusted-users = ["remotebuild"];
}
