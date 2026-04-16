# Flake schemas

> [!NOTE]
> Flake schemas are currently available only in [Determinate Nix][det-nix].
> For a broad overview, check out the [announcement post][post] on the [Determinate Systems][detsys] blog.

This [Nix flake][flakes] provides a set of schema definitions for commonly used flake output types.
[Determinate Nix][det-nix] uses these schemas by default for flakes that do not have their own `schemas` output.

Schemas determine what is shown when you run commands like [`nix flake show`][nix-flake-show].

## Provided schemas

The schemas in this repo currently cover these output types:

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

To see an example of a flake that uses a custom schema, run this command (with Determinate Nix):

```shell
nix flake show --all-systems github:DeterminateSystems/nixos-amis
```

You'll notice that there's a `diskImages` output:

```shell
├───diskImages
│   ├───aarch64-linux
│   │   └───aws: Disk image
│   └───x86_64-linux
│       └───aws: Disk image
```

This output is available because the flake provides a [dedicated schema][diskimages-schema] for `diskImages`.

## Using flake schemas

If a given flake has no `schemas` output, [Determinate Nix][det-nix] uses the schemas in this repo as its [defaults][builtin-schemas].
That means that any outputs that conform to the schemas [provided here](#provided-schemas) are covered (`devShells`, `packages`, `check`, etc.).

If a given flake *does* have a `schemas` output, [Determinate Nix][det-nix] uses that to determine the structure of the flake's outputs.
What that means is that if you want non-default schemas&mdash;as in, schemas that aren't built into Determinate Nix&mdash;you need to declare your own `schemas` output.
Here's an example of a flake that extends the schemas in this repo:

```nix
{
  inputs.flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/0";

  outputs =
    { self, ... }@inputs:
    {
      schemas = inputs.flake-schemas.schemas // {
        # other schemas here
      };

      # other outputs
    };
}
```

You can extend that with one of your own custom schemas, for example:

```nix
{
  schemas = inputs.flake-schemas.schemas // {
    myOutputs = {
      version = 1;
      doc = "The `myOutputs` flake output.";
      inventory =
        output:
        mkChildren (
          builtins.mapAttrs (system: value: {
            forSystems = [ system ];
            what = "my output";
          }) output
        );
    };
  };
}
```

Or you can extend with schemas from some other flake:

```nix
{
  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/0";
    other-flake.url = "https://flakehub.com/f/other-org/other-flake/0.1";
  };

  outputs =
    { self, ... }@inputs:
    {
      schemas = inputs.flake-schemas.schemas // inputs.other-flake.schemas;

      # other outputs
    };
}
```

You can also define schemas without involving the schemas in this repo:

```nix
{
  inputs.other-flake.url = "https://flakehub.com/f/other-org/other-flake/0.1";

  outputs =
    { self, ... }@inputs:
    {
      inherit (inputs.other-flake) schemas;

      # other outputs
    };
}
```

But be aware that when you do that, common schemas like `devShells`, `packages`, and others aren't available *unless* the flake from which you're inheriting schemas provides those.

## Development

If you're interested in developing the schemas in this repo, be sure to run the tests after making any changes:

```shell
nix flake check -L ./tests
```

To format the Nix files in this repo, run this:

```shell
nix develop ./tests -c treefmt
```

[apps]: https://manual.determinate.systems/command-ref/new-cli/nix3-run.html#apps
[builtin-schemas]: https://github.com/DeterminateSystems/nix-src/blob/main/src/libcmd/builtin-flake-schemas.nix
[bundlers]: https://github.com/nix-community/nix-bundle
[checks]: https://manual.determinate.systems/command-ref/new-cli/nix3-flake-check.html
[darwin]: https://github.com/nix-darwin/nix-darwin
[det-nix]: https://docs.determinate.systems/determinate-nix
[detsys]: https://determinate.systems
[develop]: https://manual.determinate.systems/command-ref/new-cli/nix3-develop.html
[diskimages-schema]: https://github.com/DeterminateSystems/nixos-amis/blob/6c9a4d8e7b6fc486e76f87e2acda28789aee8b7d/flake.nix#L115-L143
[flakes]: https://zero-to-nix.com/concepts/flakes
[formatter]: https://manual.determinate.systems/command-ref/new-cli/nix3-fmt.html
[home]: https://github.com/nix-community/home-manager
[hydra]: https://github.com/NixOS/hydra
[legacy]: https://github.com/NixOS/nixpkgs/blob/d1eaf1acfce382f14d26d20e0a9342884f3127b0/flake.nix#L47-L56
[nix-flake-show]: https://manual.determinate.systems/command-ref/new-cli/nix3-flake-show.html
[nixos]: https://github.com/NixOS/nixpkgs/tree/master/nixos
[nixosmodules]: https://nixos.wiki/wiki/NixOS_modules
[oci]: https://opencontainers.org
[overlays]: https://nixos.wiki/wiki/Overlays
[packages]: https://search.nixos.org/packages
[post]: https://determinate.systems/blog/introducing-flake-schemas
[templates]: https://manual.determinate.systems/command-ref/new-cli/nix3-flake-init.html
