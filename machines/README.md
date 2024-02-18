# Setting up a new machine using nixos-anywhere

```
nix run github:nix-community/nixos-anywhere -- --flake ./lattice/#lattice root@target
```

# Adding a disk to an existing machine
Don't just modify the config and try to switch to it, booting will fail because the new disk can't be mounted.

I am not sure if disko can modify disks in place non-destructively.

# Wiping disks and applying disko config interactively
‼️  This command will *wipe* all disks mentioned in the config
```
nix run github:nix-community/disko -- --mode disko ./disk-config.nix
```
