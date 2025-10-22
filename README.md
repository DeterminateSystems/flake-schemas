# Flake schemas

> [!NOTE]
> Flake schemas are not yet supported in Nix.
> You can track ongoing work in [this pull request][pr] against the upstream project.
> Until that merges, you may see this warning:
>
> ```sh
> warning: unknown flake output 'schemas'
> ```
>
> You can also [experiment with flake schemas](#experimenting-with-flake-schemas) using a candidate version of Nix.

This [Nix flake][flakes] provides a set of schema definitions for commonly used flake output types.
It's used by default for flakes that do not have a `schemas` output.

It supports the following flake output types:

* [`apps`][apps]
* [`aspects`][aspects]
* [`checks`][checks]
* [`darwinConfigurations`][darwin]
* [`darwinModules`][darwin]
* [`devShells`][develop]
* [`dockerImages`][docker]
* [`flakeModules`][flake-parts]
* [`formatter`][formatter]
* [`homeConfigurations`][home]
* [`homeModules`][home]
* [`hydraJobs`][hydra]
* [`legacyPackages`][legacy]
* [`nixosConfigurations`][nixos]
* [`nixosModules`][nixosmodules]
* [`overlays`][overlays]
* [`packages`][packages]
* `schemas`
* [`templates`][templates]

## Experimenting with flake schemas

Flake schemas are not yet supported in Nix.
To experiment with them, you can use the version of Nix from the [pull request][pr] to upstream.
Below are some example commands.

> [!WARNING]
> The first time you run one of the commands, you will build Nix in its entirety, which is resource intensive and could take a while.

```shell
# Display the flake schema for this repo
nix run github:DeterminateSystems/nix-src/flake-schemas -- \
  flake show "https://flakehub.com/f/DeterminateSystems/flake-schemas/*"

# Display the flake schema for this repo as JSON
nix run github:DeterminateSystems/nix-src/flake-schemas -- \
  flake show --json "https://flakehub.com/f/DeterminateSystems/flake-schemas/*"

# Display the flake schema for Nixpkgs
nix run github:DeterminateSystems/nix-src/flake-schemas -- \
  flake show "https://flakehub.com/f/NixOS/nixpkgs/*"

# Display the flake schema for Nixpkgs as JSON
nix run github:DeterminateSystems/nix-src/flake-schemas -- \
  flake show --json "https://flakehub.com/f/NixOS/nixpkgs/*"
```

## Read more

- [Flake schemas: Making flake outputs extensible][blog] &mdash; the blog post introducing flake schemas.
- [Flake schemas][video] &mdash; [Eelco Dolstra][eelco]'s talk on flake schemas at [NixCon 2023][nixcon-2023].

[apps]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-run#apps
[aspects]: https://github.com/vic/flake-aspects
[blog]: https://determinate.systems/posts/flake-schemas
[checks]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-check.html
[darwin]: https://github.com/LnL7/nix-darwin
[docker]: https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools
[develop]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html
[eelco]: https://determinate.systems/people/eelco-dolstra
[flake-parts]: https://flake.parts
[flakes]: https://zero-to-nix.com/concepts/flakes
[formatter]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-fmt
[home]: https://github.com/nix-community/home-manager
[hydra]: https://github.com/NixOS/hydra
[legacy]: https://github.com/NixOS/nixpkgs/blob/d1eaf1acfce382f14d26d20e0a9342884f3127b0/flake.nix#L47-L56
[nixcon-2023]: https://2023.nixcon.org
[nixos]: https://github.com/NixOS/nixpkgs/tree/master/nixos
[nixosmodules]: https://nixos.wiki/wiki/NixOS_modules
[overlays]: https://nixos.wiki/wiki/Overlays
[packages]: https://search.nixos.org/packages
[pr]: https://github.com/NixOS/nix/pull/8892
[templates]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-init
[video]: https://www.youtube.com/watch?v=ChaJY0V4ElM
