test
===

Index of tests for `require/typed/check`.

- `basic/` test simple usage, make sure contracts are applied correctly
- `bogus/` verify that type annotations are __completely ignored__ if the required module is typed
- `fsm/` larger test, has order-of-magnitude speedup from `require/typed/check`
- `opaque/` sadly, `#:opaque` types defined in typed modules are ignored
- `pr/` assorted tests, from pull requests etc.
- `submodule/` check that submodules are always assumed typed
