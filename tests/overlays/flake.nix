{
  outputs =
    { ... }:
    {
      overlays.example =
        final:
        { foo, ... }:
        {
          inherit foo;
        };
    };
}
