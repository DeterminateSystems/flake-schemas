{
  outputs =
    { self }:
    let
      mkChildren = children: { inherit children; };
    in
    {
      schemas.foo = {
        version = 1;
        doc = ''
          The `foo` output allows you to define foobars.
        '';
        inventory =
          output:
          mkChildren (
            builtins.mapAttrs (fooName: fooDef: {
              what = "foobar";
              shortDescription = fooDef.description;
              evalChecks.isValidValue = fooDef.value != 456;
            }) output
          );
      };

      foo.bar = {
        description = "hello";
        value = 123;
      };

      foo.xyzzy = {
        description = "world";
        value = 456;
      };
    };
}
