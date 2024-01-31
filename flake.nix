{
  description = "viv's nixos client base";
  inputs = { # update a single input; nix flake lock --update-input unstable
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-23.11"; };
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable-tailscale.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vivlim-nix-home = {
      url = "github:vivlim/nix-home/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, unstable, nixpkgs-unstable-tailscale, home-manager, nixos-generators, vivlim-nix-home, ... }:
    let
      # configuration = { pkgs, ... }: { nix.package = pkgs.nixflakes; }; # doesn't do anything?
      overlay = final: prev: {
        tailscale = nixpkgs-unstable-tailscale.legacyPackages.${prev.system}.tailscale;
        unstable = import unstable {
          system = prev.system;
          config = { # need to set config for each of these channels separately.
            permittedInsecurePackages = [
            ];
          };
        };
      };
      # make pkgs.unstable available in configuration.nix
      overlays = [ overlay ];
      overlayModule =
        ({ config, pkgs, ... }: {
          nixpkgs = {
            config = {
              permittedInsecurePackages = [
              ];
            };
            inherit overlays;
          };
        });
      homeManagerConfig = name: ({ config, pkgs, system, lib, utils, ... }@args: # this does not work yet
        home-manager.nixosModules.home-manager {
          inherit pkgs;
          inherit lib;
          inherit utils;
          config = {
            home-manager.users.vivlim = {
            } // (lib.attrsets.mergeAttrsList (lib.lists.forEach vivlim-nix-home.nixosModuleImports."vivlim@dev" (mod: (import mod args))));
          };
        }
      );
      moduleBundles = {
        system-base = [
          ./system-base/core.nix
          ./system-base/ssh.nix
          ./system-base/user.nix
        ];
        system-physical = [
          ./system-physical/networkmanager.nix
          ./system-physical/systemd-boot-efi.nix
        ];
        gaming-hardware = [
          ./gaming-hardware/game-controllers.nix
          ./gaming-hardware/game-controllers.nix
        ];
        amd = [
          ./hardware-specific/amd.nix
        ];
        plasma-desktop = [
          ./desktop/core.nix
          ./desktop/plasma.nix
          ./desktop/pulseaudio.nix
          ./applications/flatpak.nix
          ./applications/nix-ld.nix
        ];
      };
      machineFactory =
      { modules, system, hostname, ... }: 
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = nixpkgs.lib.lists.flatten [
            ({ config, pkgs, ... }: {
              networking.hostName = hostname;
            })
            modules
          ];
          specialArgs = {
            inherit inputs;
            channels = {
              inherit unstable;
              inherit nixpkgs;
            };
          };
        };
    in {
      nixosConfigurations = {
        basic = (machineFactory {
          system = "x86_64-linux";
          hostname = "nixos-basic";
          modules = [
            moduleBundles.system-base
            # (homeManagerConfig "vivlim@dev") this doesn't work
          ];
        });
        gui = (machineFactory {
          system = "x86_64-linux";
          hostname = "nixos-gui";
          modules = [
            moduleBundles.system-base
            moduleBundles.plasma-desktop
            moduleBundles.system-physical
            moduleBundles.gaming-hardware
          ];
        });
        amdgui = (machineFactory {
          system = "x86_64-linux";
          hostname = "nixos-amdgui";
          modules = [
            moduleBundles.system-base
            moduleBundles.plasma-desktop
            moduleBundles.system-physical
            moduleBundles.amd
            moduleBundles.gaming-hardware
          ];
        });
      };
      inherit moduleBundles;

      devShells = let
        devShellSupportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        devShellForEachSupportedSystem = f: nixpkgs.lib.genAttrs devShellSupportedSystems (system: f {
          pkgs = import nixpkgs { inherit system; inherit overlays; };
          inherit system;
        });
      in devShellForEachSupportedSystem ({ pkgs, system }: {
        default = pkgs.mkShell {
          packages = let
            build-basic = pkgs.writeShellScriptBin "build-basic" ''
              nix build .#nixosConfigurations.basic.config.system.build.vm
              ./result/bin/run-nixos-basic-vm 
            '';
            build-gui = pkgs.writeShellScriptBin "build-gui" ''
              nix build .#nixosConfigurations.gui.config.system.build.vm
              ./result/bin/run-nixos-gui-vm 
            '';
          in [
            pkgs.nil
            pkgs.nixfmt
            build-basic
            build-gui
          ];
        };
      });
    };

}
