{
  inputs.base = {
    url = "path:../../";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/d65bceaee0fb1e64363f7871bc43dc1c6ecad99f"; # nixos-23.11, from root flake. colmena won't evaluate inputs.nixpkgs.follows = "base" correctly.
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ base, nixpkgs, disko, ... }:
  let
    machineFactoryArgs = {
        hostname = "x250-micro";
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          base.moduleBundles.system-base
          base.moduleBundles.system-physical
          base.moduleBundles.plasma-desktop
          base.moduleBundles.gaming-hardware
        ];
        inherit inputs;
      };

  in
    {
      nixosConfigurations.x250-micro = base.machineFactory machineFactoryArgs;

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          specialArgs = {
            inherit inputs;
          };
        };
        x250-micro = (base.colmenaTargetFactory machineFactoryArgs)
        // {
            deployment.targetHost = "192.168.1.228";
            deployment.targetUser = "root";
        };
      };
    };
}
