# Flake schemas

This [Nix flake][flakes] provides a set of schema definitions for commonly used flake output types.
It's used by default for flakes that do not have a `schemas` output.

It supports the following flake output types:

* [`checks`][checks]
* [`devShells`][develop]
* [`hydraJobs`][hydra]
* [`legacyPackages`][legacy]
* [`nixosConfigurations`][nixos]
* [`nixosModules`][nixosmodules]
* [`overlays`][overlays]
* [`packages`][packages]
* `schemas`

## Read more

- [Flake schemas: Making flake outputs extensible][blog] &mdash; blog post introducing flake schemas.

[blog]: https://determinate.systems/posts/flake-schemas
[checks]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-check.html
[develop]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html
[flakes]: https://zero-to-nix.com/concepts/flakes
[hydra]: https://github.com/NixOS/hydra
[legacy]: https://github.com/NixOS/nixpkgs/blob/d1eaf1acfce382f14d26d20e0a9342884f3127b0/flake.nix#L47-L56
[nixos]: https://github.com/NixOS/nixpkgs/tree/master/nixos
[nixosmodules]: https://nixos.wiki/wiki/NixOS_modules
[overlays]: https://nixos.wiki/wiki/Overlays
[packages]: https://search.nixos.org/packages
