# poetry + pyright setup

When running `poetry shell`, pyright doesn't know where the venv is, which is currently in use.
To solve this problem, we need to configure poetry to create the venv in the current folder.
This is done by creating a `poetry.toml` file in the project with the following content:

```toml
[virtualenvs]
in-project = true
```

Now we need to tell pyright where the venv is.
With the settings above, poetry will create the venv in `.venv`.
So we need to add the following lines to the `pyproject.toml` file:

```toml
[tool.pyright]
venvPath = "."
venv = ".venv"
```

Now helix should have no problem finding the correct dependencies in your project!

Sources:

- [Pyright can't see Poetry dependencies](https://stackoverflow.com/questions/74510279/pyright-cant-see-poetry-dependencies)
