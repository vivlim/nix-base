{ modulesPath, config, lib, pkgs, ... }: {
  system.activationScripts.createSmbShare =
    pkgs.lib.stringAfter [ "var" ] ''
      mkdir -p /mnt/data/smbshare
    '';

  services.samba-wsdd = {
    # make shares visible for Windows clients
    enable = true;
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = lattice
      netbios name = lattice
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.1. 100.123. 127.0.0.1 localhost
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
      };
    };
  };
}
