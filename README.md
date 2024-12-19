
```
nix build .#nixosConfigurations.basic.config.system.build.toplevel
```

```
nix build .#nixosConfigurations.basic.config.system.build.vm
```

# update a nested flake's input

```
nix flake lock --update-input base
```
