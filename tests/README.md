Adding a test case:

Create a directory in the tests directory with a flake.nix and flake.lock.
Do not have any external dependencies or flake inputs.
Construct your test and then capture the output with `add-test.sh`:

```
./add-test.sh directoryName
```

like:

```
./add-test.sh devShellWithDevShellsAndPackages
```

This will create a `directoryName.json` and `directoryName.check-err` file.
If the test is not specific to the error output handling, delete the check-err file.
