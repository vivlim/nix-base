# Setting up a new machine using nixos-anywhere

```
nix run github:nix-community/nixos-anywhere -- --flake ./lattice/#lattice root@target
```

# Adding a disk to an existing machine
Don't just modify the config and try to switch to it, booting will fail because the new disk can't be mounted.

Run disko to update the partitions first.
```
nix run github:nix-community/disko -- --mode disko ./disk-config.nix
```
