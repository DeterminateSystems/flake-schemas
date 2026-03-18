{
  outputs = { self, ... }:
  {
    lib.makeShellTestCase = name: derivation {
      inherit name;
      system = "x86_64-linux";
      builder = "/bin/bash";
      args = [ "-c" "echo $name; echo $name; echo $name; echo $name; echo $name; " ];
    };

    devShell.x86_64-linux = self.lib.makeShellTestCase "devShell-legacy";
  };
}
