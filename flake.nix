{
  description = "viv's nixos client base";
  inputs = { # update a single input; nix flake lock --update-input unstable
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-23.11"; };
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable-tailscale.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = inputs@{ self, nixpkgs, unstable, nixpkgs-unstable-tailscale, nixos-generators, vscode-server, ... }:
    let
      # configuration = { pkgs, ... }: { nix.package = pkgs.nixflakes; }; # doesn't do anything?
      overlay = final: prev: {
        unstable-tailscale = nixpkgs-unstable-tailscale.legacyPackages.${prev.system}.tailscale;
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
      moduleBundles =
      rec {
        system-base = [
          ./system-base/core.nix
          ./system-base/ssh.nix
          ./system-base/user.nix
          ./applications/tools.nix
        ] ++ nixosModules;
        server-base = [
          ./system-base/glances.nix
        ] ++ system-base;
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
          ./applications/nix-ld.nix
          ./applications/gui-tools.nix
          ./applications/vlc.nix
        ];
        plasma-desktop-full = plasma-desktop ++ [
          ./applications/flatpak.nix
        ];
        pulseaudio = [
          ./desktop/pulseaudio.nix
        ];
        nixosModules = [ # 'true' nixos modules that don't do anything on their own but add configuration options that machines can use.
          ./modules/prometheus_exporters.nix
          ./modules/swap_defaults.nix
        ];
        obs = [ # todo: refactor to enumerate the modules so i can pick and choose individually.
          ./applications/obs.nix
        ];
        dev = [
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: {
            services.vscode-server.enable = true;
          })
        ];
      };
      machineFactory =
      { modules, system, hostname, inputs, ... }: 
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

      colmenaTargetFactory =
      ({ modules, system, hostname, inputs, ... }: 
        {
          networking.hostName = hostname;
          imports = nixpkgs.lib.lists.flatten modules;
        });
    in {
      inherit moduleBundles;
      inherit machineFactory;
      inherit colmenaTargetFactory;
      src = ./.;

      nixosConfigurations = {
        basic = (machineFactory {
          system = "x86_64-linux";
          hostname = "nixos-basic";
          inherit inputs;
          modules = [
            moduleBundles.system-base
            moduleBundles.dev
          ];
        });
        gui = (machineFactory {
          system = "x86_64-linux";
          hostname = "nixos-gui";
          inherit inputs;
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
          inherit inputs;
          modules = [
            moduleBundles.system-base
            moduleBundles.plasma-desktop
            moduleBundles.system-physical
            moduleBundles.amd
            moduleBundles.gaming-hardware
          ];
        });
      };

      packages.x86_64-linux = {
        pc-efi = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "raw-efi";
          specialArgs = {
            inherit inputs;
          };
          modules = nixpkgs.lib.lists.flatten [
            moduleBundles.system-base
            moduleBundles.plasma-desktop
            moduleBundles.system-physical
            moduleBundles.gaming-hardware
            ({ config, pkgs, ... }: {
              networking.hostName = "viv-nixos-graphical-efi";
              boot.growPartition = true; # Make the rootfs bigger if there's space
            })
          ];
        };
      };

      devShells = let
        devShellSupportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        devShellForEachSupportedSystem = f: nixpkgs.lib.genAttrs devShellSupportedSystems (system: f {
          pkgs = import nixpkgs { inherit system; inherit overlays; };
          inherit system;
        });
      in devShellForEachSupportedSystem ({ pkgs, system }: {
        default = pkgs.mkShell {
          packages = let
            build-gui = pkgs.writeShellScriptBin "build-gui" ''
              nix build .#nixosConfigurations.gui.config.system.build.vm
              ./result/bin/run-nixos-gui-vm 
            '';
          in [
            pkgs.nil
            pkgs.nixfmt
            build-gui
          ];
        };
      });
    };

}
