# Conventional commit types

For [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/),
in addition to the default types

- `fix`: patches a bug
- `feat`: introduces a new feature to the codebase

Evan uses the following types:

- `build`: build related
- `ci`: work related to CI
- `chore`: updating deps, etc.
- `docs`: documentation changes
- `drop`: deleting stuff or removing a feature
- `edit`: minor changes that don't constitute a new feature
- `perf`: performance improvements
- `polish`: copy editing or cleanup that doesn't affect functionality
- `root`: an empty root commit (i.e. the first commit of the repository)
- `refactor`: major rewriting or restructuring that doesn't fix bugs or affect functionality
- `revert`: revert commits
- `style`: code style changes
- `test`: unit testing, etc.

See [the corresponding GitHub action](.github/workflows/conv-commit.yml).
