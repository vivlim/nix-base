{ modulesPath, config, lib, pkgs, ... }: {
  config.system.activationScripts.createLemmyContainerPaths =
    pkgs.lib.stringAfter [ "var" ] ''
      mkdir /mnt/data/smbshare
    '';

  services.samba-wsdd = {
    # make shares visible for Windows clients
    enable = true;
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = lattice
      netbios name = lattice
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      share = {
        path = "/mnt/data/smbshare";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = "username";
        "force group" = "groupname";
      };
    };
  };
}
