{
  inputs.base = {
    url = "path:./../../";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.oom-hardware.url = "github:vivlim/oom-hardware";
  inputs.oom-hardware.inputs.nixpkgs.follows = "nixpkgs";
  inputs.oom-hardware.inputs.nixos-hardware.follows = "nixos-hardware";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ base, nixpkgs, nixos-hardware, oom-hardware, nixos-generators, ... }:
  let
    modules = [
          ./configuration.nix
          ./uconsole.nix
          ./substituter.nix
          ./remotebuild.nix
          ./arm.nix
          base.moduleBundles.system-base
          base.moduleBundles.plasma-desktop
          base.moduleBundles.gaming-hardware
          nixos-hardware.nixosModules.raspberry-pi-4
          oom-hardware.uconsole.kernel
          oom-hardware.raspberry-pi.overlays
          oom-hardware.raspberry-pi.apply-overlays
          ({ pkgs, ... }: {
            environment.systemPackages = [
              (pkgs.callPackage oom-hardware.raspberry-pi.rpi-utils {})
            ];
          })
        ];
    machineFactoryArgs = {
        hostname = "aarchduke";
        system = "aarch64-linux";
        modules = modules ++ [./hwconfig-nonsdimage.nix];
        inherit inputs;
      };
  in {
      nixosConfigurations.aarchduke = base.machineFactory machineFactoryArgs;

      sdImage = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = nixpkgs.lib.lists.flatten modules ++ [./sdimage.nix];
        specialArgs = {
          inherit inputs;
        };
      };

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "aarch64-linux";
          };
          specialArgs = {
            inherit inputs;
          };
        };
        aarchduke = (base.colmenaTargetFactory machineFactoryArgs)
        // {
            deployment.targetHost = "aarchduke.cow-bebop.ts.net";
            deployment.targetUser = "root";
        };
      };
    };
}
