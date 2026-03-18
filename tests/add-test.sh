#!/bin/sh

flake=$1

nix flake show --offline --json --legacy --default-flake-schemas "../" "./$flake" \
  | jq \
  | tee "$flake.json"

nix flake check --offline --no-build --default-flake-schemas "../" "./$flake" --no-eval-cache 2>&1 \
    | (grep -v '^evaluating ' || true) \
    | tee "$flake.check-err"
