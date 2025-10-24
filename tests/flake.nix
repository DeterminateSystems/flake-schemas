{
  inputs.flake-schemas.url = "path:..";
  # FIXME: use regular Nix after flake-schemas have been merged.
  inputs.nix.url = "github:DeterminateSystems/nix-src/flake-schemas-detsys";
  inputs.nixpkgs.follows = "nix/nixpkgs";

  outputs =
    {
      self,
      flake-schemas,
      nix,
      nixpkgs,
    }:
    {

      devShells.x86_64-linux.default = self.checks.x86_64-linux.formatting;

      checks.x86_64-linux.formatting =
        with nixpkgs.legacyPackages.x86_64-linux;

        runCommand "formatting"
          {
            buildInputs = [ nixfmt-tree ];
            src = flake-schemas;
          }
          ''
            treefmt --ci "$src"
            mkdir "$out"
          '';

      checks.x86_64-linux.checkSchemas =
        with nixpkgs.legacyPackages.x86_64-linux;

        runCommand "check-schemas"
          {
            buildInputs = [
              nix.packages.x86_64-linux.nix
              writableTmpDirAsHomeHook
              wdiff
              jq
            ];
            src = flake-schemas;
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
                  wdiff "$src/tests/$flake.check-err" "$flake.check-err"
                else
                  exit 1
                fi
              fi
            done

            mkdir "$out"
          '';
    };
}
