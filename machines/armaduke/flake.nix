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
    machineFactoryArgs = {
        hostname = "armaduke";
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          base.moduleBundles.system-base
        ];
        inherit inputs;
      };

  in
    {
      nixosConfigurations.armaduke = base.machineFactory machineFactoryArgs;
    };
}
