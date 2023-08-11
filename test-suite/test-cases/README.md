# Tests

## Test configuration

Test suite configuration is defined at `config.toml` in this directory.

For each test case, an `interface`, `runner` and a list of languages implementing this test case must be defined.

### Adding an implementation of existing test case in a new language

To add a test case implementation in a new language, add the language in the `languages` array in `config.toml` for the appropriate test case and update `.github/workflows/test-suite.yml` to include your test case in the build matrix.

For example, for implementation of test case `foo` in language `bar`:

1. Implement the test case at `../languages/bar/foo` directory
2. Add `bar` in `languages` field of `foo` in `config.toml`
3. Add `test-case-foo-bar-wasm32-unknown` and `test-case-foo-bar-wasm32-wasi` in `package` matrix for the `build` job in `.github/workflows/test-suite.yml`.

### Adding a new test case

To add a new test case, define the `interface` and `runner` in `config.toml` under a new name and add the implementation of the test runner at the appropriate location.

For example, for test case `foo` with runner in language `bar`:

1. Implement the test case runner at `../languages/bar/foo-runner` directory
2. Add `foo` table in `config.toml` containing appropriate `interface` name and `runner` set to `bar`

## Test cases

### Numbers

Tests basic number stuff
