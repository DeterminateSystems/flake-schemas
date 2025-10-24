{
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";

  outputs =
    { self, nixpkgs }:
    {
      legacyPackages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

      # The schema should recurse into attrsets that have recurseForDerivations.
      legacyPackages.x86_64-linux.pythonPackages = {
        recurseForDerivations = true;
        inherit (nixpkgs.legacyPackages.x86_64-linux.pythonPackages) python lxml;
      };

      # But not attrsets that don't have that.
      legacyPackages.x86_64-linux.foo = {
        bar = nixpkgs.legacyPackages.x86_64-linux.hello;
      };

      # FIXME: doesn't work with `nix flake check` yet.
      #legacyPackages.x86_64-linux.fail1 =
      #  assert false;
      #  123;
      #legacyPackages.x86_64-linux.fail2 = throw "not supported";
    };
}
