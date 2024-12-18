{ config, lib, pkgs, modulesPath, ... }:

{
  nix.settings = {
    substituters = ["https://cache-nix.project2.xyz/uconsole"];
    trusted-substituters = ["https://cache-nix.project2.xyz/uconsole"];
    trusted-public-keys = ["uconsole:t2pv3NWEtXCYY0fgv9BB8r9tRdK+Tz7HYhGq9bXIIck="];
  };
}
