{
  inputs.base = {
    url = "path:./../../";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ base, nixpkgs, disko, ... }:
  let
    modules = [
      ./configuration.nix
      ./disk-config.nix
      base.moduleBundles.system-base
      disko.nixosModules.disko
    ];
    factoryArgs = {
        hostname = "cliffarmd";
        system = "aarch64-linux";
        inherit modules;
        inherit inputs;
    };
  in
    {
      nixosConfigurations.cliffarmd = base.machineFactory factoryArgs;

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "aarch64-linux";
          };
          specialArgs = {
            inherit inputs;
          };
        };
        apiary = (base.colmenaTargetFactory factoryArgs)
        // {
            deployment.targetHost = "cliffarmd";
            deployment.targetUser = "root";
        };
      };
    };
}
