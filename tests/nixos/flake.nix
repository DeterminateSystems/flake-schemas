{
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";

  outputs =
    { self, nixpkgs }:
    {

      nixosConfigurations.machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            fileSystems."/".device = "/dev/sda1";
            boot.loader.grub.devices = [ "/dev/sda" ];
          }
        ];
      };

    };
}
