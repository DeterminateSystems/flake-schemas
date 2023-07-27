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
          { doc = "A schema checker for the `${schemaName}` flake output.";
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
          The `legacyPackages` flake output *bla bla...*
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

      # FIXME: remove?
      lib.evalFlake = flake: rec {

        allSchemas = flake.outputs.schemas or self.schemas;

        schemas =
          builtins.listToAttrs (builtins.concatLists (mapAttrsToList (outputName: output:
            if allSchemas ? ${outputName} then
              [ { name = outputName; value = allSchemas.${outputName}; }]
            else
              [ ])
            flake.outputs));

        docs =
          builtins.mapAttrs (outputName: schema: schema.doc or "<no docs>") schemas;

        uncheckedOutputs =
          builtins.filter (outputName: ! schemas ? ${outputName}) (builtins.attrNames flake.outputs);

        inventoryFor = filterFun:
          builtins.mapAttrs (outputName: schema:
            let
              doFilter = attrs:
                if filterFun attrs
                then
                  if attrs ? children
                  then
                    mkChildren (builtins.mapAttrs (childName: child: doFilter child) attrs.children)
                  else if attrs ? leaf then
                    mkLeaf {
                      forSystems = attrs.leaf.forSystems or null;
                      doc = if attrs.leaf ? doc then try attrs.leaf.doc "«evaluation error»" else null;
                      #evalChecks = attrs.leaf.evalChecks or {};
                    }
                  else
                    throw "Schema returned invalid tree node."
                else
                  {};
            in doFilter ((schema.inventory or (output: {})) flake.outputs.${outputName})
          ) schemas;

        inventoryForSystem = system: inventoryFor (itemSet:
          !itemSet ? forSystems
          || builtins.any (x: x == system) itemSet.forSystems);

        inventory = inventoryFor (x: true);

        contents = {
          inherit docs;
          inherit inventory;
        };
      };
    };
}
