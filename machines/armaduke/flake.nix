{
  inputs.base = {
    url = "path:./../../";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ base, nixpkgs, disko, ... }:
  let
    modules = [
      ./configuration.nix
      ./remotebuild.nix
      ./remotebuilder.nix
      base.moduleBundles.system-base
    ];
  in
    {
      nixosConfigurations.armaduke = base.machineFactory {
        hostname = "armaduke";
        system = "aarch64-linux";
        inherit modules;
        inherit inputs;
      };
    };
}
