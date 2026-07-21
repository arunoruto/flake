---
name: python-docstrings-numpy
description: Enforces NumPy-style Python docstrings for Python code
---

# Python Docstring Rules

Use this skill when reviewing or writing Python docstrings.

## Purpose and scope

- Use NumPy-style docstrings.
- Focus on public Python modules, classes, functions, and methods.
- Keep docstrings compact, specific, and easy to scan.

## Request changes when

- a public API has no docstring;
- the summary line is vague or inaccurate;
- arguments, returns, or intentionally raised exceptions are undocumented;
- a non-trivial public API needs an example but does not have one.

## Section ordering

Sections must appear in this order. All sections except the short summary are optional.

1. Short summary
2. Deprecation warning
3. Extended summary
4. `Parameters`
5. `Returns`
6. `Yields` (generators only; use instead of `Returns`)
7. `Raises`
8. `Warns`
9. `See Also`
10. `Notes`
11. `References`
12. `Examples`

## Formatting rules

- Limit docstrings to 75 characters per line.
- Section headers must be underlined with dashes matching the header length.
- The short summary must not use variable names or the function name.

### Parameters

- Format: `name : type` on its own line, description indented on the following line(s).
- When type is omitted, the colon after the name is also omitted.
- Use `name : type, optional` for keyword arguments.
- For defaults: `name : type, default value` or `name : type, default: value`.
- For enumerated values: `name : {'value1', 'value2'}` (default first).
- Combine parameters with the same type/description: `x1, x2 : type`.
- Variable positional/keyword args: `*args` / `**kwargs` (no type, keep the stars).
- Reference parameter names elsewhere in the docstring in single backticks: `` `param` ``.

### Returns

- Format is the same as `Parameters` but the name is optional.
- When both name and type are given: `name : type` with indented description.
- When only the type: `type` on its own line with indented description.

### Yields

- For generators. Same format as `Returns`.

### Raises / Warns

- Exception type on its own line, description indented below.

### See Also

- List related functions. Format: `func_name : description` or just `func_name`.

### Notes

- For algorithm discussion, implementation details, math (LaTeX), or images.
- Keep math and images minimal — the docstring must be readable as plain text.

### reST conventions

- Triple double quotes (`"""`) for all docstrings.
- Single backticks for names that should hyperlink: module, class, function, method, parameter names.
- Double backticks for monospaced code: ``` ``code`` ```.

## Class docstrings

- Document `__init__` parameters in the class docstring (not in `__init__`).
- Do not list `self` as a parameter.
- Use an `Attributes` section after `Parameters` for non-method attributes.
- Attributes can be listed by name only (no type/description) if they have their own docstrings.
- A `Methods` section may be added for large classes with many methods, but is usually unnecessary (public methods are already visible).

## Reviewer checklist

- Is the docstring present on the public API?
- Is the summary line accurate?
- Are sections in the correct order?
- Are inputs, outputs, and exceptions documented?
- Would a user understand how to call this API from the docstring alone?
- Are parameter names and code references using correct backtick conventions?

## Examples

### Function

```python
def my_function(param1: int, param2: str = "default") -> bool:
    """Short description.

    Extended summary explaining functionality.

    Parameters
    ----------
    param1 : int
        Explanation of ``param1``.
    param2 : str, optional
        Explanation of ``param2``. Default is ``"default"``.

    Returns
    -------
    bool
        Explanation of the return value.

    Examples
    --------
    >>> my_function(1, "test")
    True
    """
    return True
```

### Class

```python
class MyClass:
    """Short description.

    Extended summary.

    Parameters
    ----------
    param1 : int
        Description of ``param1``.
    param2 : str
        Description of ``param2``.

    Attributes
    ----------
    param1 : int
        Description of ``param1``.
    param2 : str
        Description of ``param2``.
    computed : float
        A computed value, available after initialization.

    Examples
    --------
    >>> obj = MyClass(param1=1, param2="test")
    >>> obj.param1
    1
    >>> obj.param2
    'test'
    """
    def __init__(self, param1: int, param2: str) -> None:
        self.param1 = param1
        self.param2 = param2
        self.computed = float(param1)
```
