# Python Module

Module
: A file containing Python definitions and statements

The file name is the module name with `.py` suffixed.

The module is name is available in the module as a string with the global `__name__` variable.

A module can contain statements, which are intended to initialize the module. These are executed only the first time a module is imported, or when a module is executed as a script.

A module has its own private namespace. This namespace is the global namespace within the module.

You can import modules like

```python
import <module-name>
# Let's you import names directly into the caller's namespace.
# Doesn't import the module name itself.
from <module-name> import <name-in-module> 
# Imports everything except the names starting with _
from <module-name> import *
# Import module name as a different name
import <module-name> as different-name
# Import names within a module as a different name
from <module-name> import <name-in-module> as different-name 
```

## Running Module as Scripts

You can run a module:

```bash
$ python foo.py <args>
```

When running as a script the `__name__` global variable is set to `"__main__"`

You can use this fact to have that only runs during scripts, and not imports.

```python
if __name__ == "__main__":
    print("HELLO")
```

## Module Search Path

Python searches three places when trying to import a module:

1. Directory containing the script, or current directory if no file is specified.
1. `$PYTHONPATH` (a list of directory names, with the same syntax as the shell variable PATH).
1. The installation-dependent default

The search path is accessible in python via `sys.path` variable.

## `dir()`

The built-int function `dir()` returns all names defined for the module.

## Packages

Packages
: allows a way to structure module namespaces

```
cool-package/
├── __init__.py
├── sub-pkg-1/
│   ├── __init__.py
│   └── foo.py
└── sub-pkg-2/
    ├── __init__.py
    └── bar.py
```

The `__init__.py` files are required to make Python treat directories containing the file as packages. It can be empty or contain initialization code.

You can then import packages using dot notation.

```python
import cool-package.sub-pkg-1.foo

# Then we can use it via the full name
cool-package.sub-pkg-1.foo.do("HI")
```

alternatively

```python
from cool-package.sub-pkg-1 import foo

foo.do("HI")
```

or even

```python
from cool-package.sub-pkg-1.foo import do

do("HI")
```

### Importing `*` From a Package

TODO