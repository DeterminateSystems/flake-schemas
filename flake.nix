{
  description = "Schemas for well-known Nix flake output types";

  outputs = { self }:

    let

      mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (builtins.attrNames attrs);

      checkDerivation = drv:
        drv.type or null == "derivation"
        && drv ? drvPath;

      schemasSchema = {
        version = 1;
        doc = ''
          The `schemas` flake output is used to define and document flake outputs.

          # Example

          Bla bla

          ```nix
          ...
          ```
        '';
        inventory = output: mkChildren (builtins.mapAttrs (schemaName: schemaDef:
          mkLeaf {
            doc = "A schema checker for the `${schemaName}` flake output.";
            evalChecks.isValidSchema =
              schemaDef.version or 0 == 1
              && schemaDef ? doc
              && builtins.isString (schemaDef.doc)
              && schemaDef ? inventory
              && builtins.isFunction (schemaDef.inventory);
          }) output);
      };

      packagesSchema = {
        version = 1;
        doc = ''
          The `packages` flake output contains packages that can be added to a shell using `nix shell`.
        '';
        inventory = derivationsInventory false;
      };

      legacyPackagesSchema = {
        version = 1;
        doc = ''
          The `legacyPackages` flake output is similar to `packages`, but it can be nested (i.e. contain attribute sets that contain more packages).
          Since enumerating the packages in nested attribute sets is inefficient, `legacyPackages` should be avoided in favor of `packages`.
        '';
        inventory = output:
          mkChildren (builtins.mapAttrs (systemType: packagesForSystem:
            { forSystems = [ systemType ];
              children =
                let
                  recurse = prefix: attrs: builtins.listToAttrs (builtins.concatLists (mapAttrsToList (attrName: attrs:
                    # Necessary to deal with `AAAAAASomeThingsFailToEvaluate` etc. in Nixpkgs.
                    try (
                      if attrs.type or null == "derivation" then
                        [ { name = attrName;
                            value = mkLeaf {
                              forSystems = [ attrs.system ];
                              doc = attrs.meta.description or null;
                              #derivations = [ attrs ];
                              evalChecks.isDerivation = checkDerivation attrs;
                            };
                          }
                        ]
                      else
                        # Recurse at the first and second levels, or if the
                        # recurseForDerivations attribute if set.
                        if attrs.recurseForDerivations or false
                        then
                          [ { name = attrName;
                              value.children = recurse (prefix + attrName + ".") attrs;
                            }
                          ]
                        else
                          [ ])
                      [ ])
                    attrs));
                in
                  # The top-level cannot be a derivation.
                  assert packagesForSystem.type or null != "derivation";
                  recurse (systemType + ".") packagesForSystem;
            }) output);
      };

      checksSchema = {
        version = 1;
        doc = ''
          The `checks` flake output contains derivations that will be built by `nix flake check`.
        '';
        inventory = derivationsInventory true;
      };

      devShellsSchema = {
        version = 1;
        doc = ''
          The `devShells` flake output contains derivations that provide a build environment for `nix develop`.
        '';
        inventory = derivationsInventory false;
      };

      hydraJobsSchema = {
        version = 1;
        doc = ''
          The `hydraJobs` flake output defines derivations to be built
          by the Hydra continuous integration system.
        '';
        allowIFD = false;
        inventory = output:
          let
            recurse = prefix: attrs: mkChildren (builtins.mapAttrs (attrName: attrs:
              if attrs.type or null == "derivation" then
                mkLeaf {
                  forSystems = [ attrs.system ];
                  doc = attrs.meta.description or null;
                  #derivations = [ attrs ];
                  evalChecks.isDerivation = checkDerivation attrs;
                }
              else
                recurse (prefix + attrName + ".") attrs
            ) attrs);
          in
            # The top-level cannot be a derivation.
            assert output.type or null != "derivation";
            recurse "" output;
      };

      overlaysSchema = {
        version = 1;
        doc = ''
          The `overlays` flake output defines "overlays" that can be plugged into Nixpkgs.
          Overlays add additional packages or modify or replace existing packages.
        '';
        allowIFD = false;
        inventory = output: mkChildren (builtins.mapAttrs (overlayName: overlay:
          mkLeaf {
            evalChecks.isOverlay =
              # FIXME: should try to apply the overlay to an actual
              # Nixpkgs.  But we don't have access to a nixpkgs
              # flake here. Maybe this schema should be moved to the
              # nixpkgs flake, where it does have access.
              builtins.isAttrs (overlay {} {});
          }) output);
      };

      # Helper functions.

      try = e: default:
        let res = builtins.tryEval e;
        in if res.success then res.value else default;

      mkChildren = children: { inherit children; };
      mkLeaf = leaf: { inherit leaf; };

      derivationsInventory = isCheck: output: mkChildren (
        builtins.mapAttrs (systemType: packagesForSystem:
          {
            forSystems = [ systemType ];
            children = builtins.mapAttrs (packageName: package:
              mkLeaf {
                forSystems = [ systemType ];
                doc = package.meta.description or null;
                derivations = if isCheck then [ package ] else [ ];
                evalChecks.isDerivation = checkDerivation package;
              }) packagesForSystem;
          })
          output);

    in

    {
      # FIXME: distinguish between available and active schemas?
      schemas.schemas = schemasSchema;
      schemas.packages = packagesSchema;
      schemas.legacyPackages = legacyPackagesSchema;
      schemas.checks = checksSchema;
      schemas.devShells = devShellsSchema;
      schemas.hydraJobs = hydraJobsSchema;
      schemas.overlays = overlaysSchema;
    };
}
