{
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";

  outputs =
    { self, nixpkgs }:
    {
      packages.aarch64-linux.hello = nixpkgs.legacyPackages.aarch64-linux.hello;
      packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    };
}
