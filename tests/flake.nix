{
  inputs.flake-schemas.url = "path:..";
  # FIXME: use regular Nix after flake-schemas have been merged.
  inputs.nix.url = "github:DeterminateSystems/nix-src/flake-schemas-detsys";
  inputs.nixpkgs.follows = "nix/nixpkgs";

  outputs =
    {
      self,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { system, ... }:
        {
          default = self.checks.${system}.formatting;
        }
      );

      checks = forEachSupportedSystem (
        { pkgs, system }:
        {
          formatting =
            pkgs.runCommand "formatting"
              {
                buildInputs = with pkgs; [ nixfmt-tree ];
                src = inputs.flake-schemas;
              }
              ''
                treefmt --ci "$src"
                mkdir "$out"
              '';

          checkSchemas =
            pkgs.runCommand "check-schemas"
              {
                buildInputs = with pkgs; [
                  inputs.nix.packages.${system}.nix
                  writableTmpDirAsHomeHook
                  wdiff
                  jq
                ];
                src = inputs.flake-schemas;
              }
              ''
                set -o pipefail

                # FIXME: this is slow, figure out a faster way (like the overlay store).
                echo "Copying flake inputs for the tests..."
                nix store add --offline --name source ${builtins.fetchTree ((builtins.fromJSON (builtins.readFile ./nixos/flake.lock)).nodes.nixpkgs.locked)}

                # Run the `nix flake show` and `nix flake check` tests.
                for json_exp in $src/tests/*.json; do
                  flake=$(basename "$json_exp" .json)

                  echo "Running 'nix flake show' on '$flake'..."
                  nix flake show --offline --json --legacy --default-flake-schemas "$src" "$src/tests/$flake" | jq > "$flake.json"
                  wdiff "$json_exp" "$flake.json"
                  printf "\n"

                  echo "Running 'nix flake check' on '$flake'..."
                  # FIXME: check what checks would have been done without `--no-build`.
                  if ! nix flake check --offline --no-build --default-flake-schemas "$src" "$src/tests/$flake" --no-eval-cache 2>&1 | (grep -v '^evaluating ' || true) | tee "$flake.check-err"; then
                    if [[ -e "$src/tests/$flake.check-err" ]]; then
                      # `nix flake check` processes attributes in an undefined order, so sort the output.
                      wdiff <(sort < $src/tests/$flake.check-err) <(sort < "$flake.check-err")
                    else
                      exit 1
                    fi
                  fi
                done

                if [ $system = "x86_64-linux" ]; then
                  # Check that `nix develop` reads devShell.system if no other option is available
                  nix develop --system x86_64-linux --offline --default-flake-schemas "$src" "$src/tests/devShell" --no-eval-cache 2>&1 | tee /dev/stderr | grep -q "devShell-legacy"

                  # Check that `nix develop` reads devShells.system.default over devShell.system
                  nix develop --system x86_64-linux --offline --default-flake-schemas "$src" "$src/tests/devShellWithDevShells" --no-eval-cache 2>&1 | tee /dev/stderr | grep -q "devShells-preferred-over-legacy"

                  # Check that `nix develop` reads devShell.system when packages.system.default is also available
                  nix develop --system x86_64-linux --offline --default-flake-schemas "$src" "$src/tests/devShellWithPackages" --no-eval-cache 2>&1 | tee /dev/stderr | grep -q "devShell-legacy-preferred-over-packages"

                  # Check that `nix develop` reads devShells.system.default over devShell.system and packages.
                  nix develop --system x86_64-linux --offline --default-flake-schemas "$src" "$src/tests/devShellWithDevShellsAndPackages" --no-eval-cache 2>&1 | tee /dev/stderr | grep -q "devShells-preferred-over-legacy-and-packages"
                fi

                mkdir "$out"
              '';
        }
      );
    };
}
