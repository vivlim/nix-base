{ ... }:

{
  # https://discourse.nixos.org/t/flake-to-create-a-simple-sd-image-for-rpi4-cross/35185/25
  # Disabling the whole `profiles/base.nix` module, which is responsible
  # for adding ZFS and a bunch of other unnecessary programs:
  disabledModules = [
    "profiles/base.nix"
  ];

  # allow build to pass without all modules being present
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];
}
