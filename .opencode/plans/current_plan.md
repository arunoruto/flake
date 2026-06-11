# Development Namespace Migration

- Use `development.*` as the shared parent namespace for user and project development environments.
- Home-manager target should read `development.languages.*` and `development.defaultEditor`.
- Home-manager-native editor installation remains under `programs.<editor>.*`.
- The current home-manager adapter may remain under `modules/home-manager/devenv` temporarily, but its public API should no longer be `devenv.*`.
- Module tree is named `modules/devix/` to keep it independent from the Cachix `devenv` project.
- Expose the home-manager target as `homeModules.devix`; keep `homeModules.default` as the local full home stack.
