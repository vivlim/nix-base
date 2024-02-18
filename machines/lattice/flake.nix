{
  inputs.base = {
    url = "path:../../";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/d65bceaee0fb1e64363f7871bc43dc1c6ecad99f"; # nixos-23.11, from root flake. colmena won't evaluate inputs.nixpkgs.follows = "base" correctly.
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { base, nixpkgs, disko, ... }:
  let
    machineFactoryArgs = {
        hostname = "lattice";
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./samba.nix
          base.moduleBundles.server-base
        ];
      };

  in
    {
      nixosConfigurations.lattice = base.machineFactory machineFactoryArgs;

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        };
        lattice = (base.colmenaTargetFactory machineFactoryArgs)
        // {
            deployment.targetHost = "192.168.1.169";
            deployment.targetUser = "root";
        };
      };
    };
}
