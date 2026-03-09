# Flake schemas

This [Nix flake][flakes] provides a set of schema definitions for commonly used flake output types.
[Determinate Nix][det-nix] uses these schemas by default for flakes that do not have their own `schemas` output.

The currently covered output types:

* [`apps`][apps]
* [`bundlers`][bundlers]
* [`checks`][checks]
* [`darwinConfigurations`][darwin]
* [`darwinModules`][darwin]
* [`devShells`][develop]
* [`formatter`][formatter]
* [`homeConfigurations`][home]
* [`homeModules`][home]
* [`hydraJobs`][hydra]
* [`legacyPackages`][legacy]
* [`nixosConfigurations`][nixos]
* [`nixosModules`][nixosmodules]
* [`ociImages`][oci]
* [`overlays`][overlays]
* [`packages`][packages]
* `schemas`
* [`templates`][templates]

## Development

After making changes to `flake-schemas`, be sure to run the tests:

```shell
nix flake check -L ./tests
```

To apply formatting, run the following:

```shell
nix develop ./tests -c treefmt
```

[apps]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-run#apps
[bundlers]: https://github.com/nix-community/nix-bundle
[checks]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-check.html
[darwin]: https://github.com/nix-darwin/nix-darwin
[det-nix]: https://docs.determinate.systems/determinate-nix
[develop]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html
[flakes]: https://zero-to-nix.com/concepts/flakes
[formatter]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-fmt
[home]: https://github.com/nix-community/home-manager
[hydra]: https://github.com/NixOS/hydra
[legacy]: https://github.com/NixOS/nixpkgs/blob/d1eaf1acfce382f14d26d20e0a9342884f3127b0/flake.nix#L47-L56
[nixos]: https://github.com/NixOS/nixpkgs/tree/master/nixos
[nixosmodules]: https://nixos.wiki/wiki/NixOS_modules
[oci]: https://opencontainers.org
[overlays]: https://nixos.wiki/wiki/Overlays
[packages]: https://search.nixos.org/packages
[templates]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-init
