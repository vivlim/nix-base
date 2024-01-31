
{ config, pkgs, options, ... }: {
  users.users.vivlim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    uid = 1000;
  };
}
