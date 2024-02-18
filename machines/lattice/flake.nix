{
  inputs.base = {
    url = "path:../../";
  };
  inputs.nixpkgs.follows = "base";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "base";

  outputs = { base, nixpkgs, disko, ... }:
  let
    machineFactoryArgs = {
        hostname = "lattice";
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
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
