---
name: devenv
description:
  Guide for using devenv, the Nix-based developer environment manager. Use this
  to ensure all commands run in the isolated, correct system environment.
---

# devenv

`devenv` is a tool that uses Nix to provide fast, declarative, and reproducible developer environments. It ensures that system-level dependencies (like specific versions of Python, Rust, or C libraries) are isolated to the project.

## The Golden Rule: Context Loss

In non-interactive AI shell sessions, environment variables injected by tools like `direnv` are frequently lost.

**Whenever you execute a project command, you MUST wrap it in `devenv shell --`**. This guarantees the command runs with the correct Nix-provided dependencies and prevents falling back to the host system's global binaries.

## Interacting with Python and `uv`

Because this project uses both `devenv` (for system packages) and `uv` (for Python packages), you must combine them for execution. `devenv` provides the environment, and `uv` runs the script within it.

### Executing Python Scripts

```bash
# Bad (uses global system python)
python main.py

# Bad (uses global uv, might miss Nix dependencies)
uv run python main.py

# Good (Hydrates Nix environment, then runs uv)
devenv shell -- uv run python main.py
```

### Running Tests

```bash
# Bad
pytest tests/

# Good
devenv shell -- uv run pytest tests/
```

### Adding Python Dependencies

```bash
# Bad
uv add requests

# Good
devenv shell -- uv add requests
```

## Key `devenv` Commands

**Use when:** You need to manage the Nix environment itself, check statuses, or run background processes.

```bash
devenv shell -- <cmd>    # Run a command inside the isolated environment
devenv info              # Show information about the current environment
devenv up                # Start any background processes/services defined in devenv.nix
devenv update            # Update the flake.lock and nixpkgs versions
devenv clean             # Clean up the environment symlinks
```

## Modifying the Environment (`devenv.nix`)

The environment is configured declaratively in `devenv.nix`.

**When to modify:**

- If a Python package fails to install because it is missing a system-level C-compiler or shared library (like `openssl`, `libffi`, etc.).
- If you need to add a non-Python tool to the project (e.g., `jq`, `curl`, `postgresql`).

**How to add system packages:**
Add the Nix package name to the `packages` list in `devenv.nix`:

```nix
{ pkgs, ... }: {
  packages = [
    pkgs.git
    pkgs.zlib
    pkgs.libffi
  ];
}
```

_Note: Do not run `nix-env -iA` or `nix profile install`. Always modify `devenv.nix`._
