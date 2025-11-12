{
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";

  outputs =
    { self, nixpkgs }:
    {
      checks.aarch64-linux.hello = nixpkgs.legacyPackages.aarch64-linux.hello;
      checks.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    };
}
