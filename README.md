# bash_pymport
Python-like import, which allows to include only specific functions/variables from an external script

## Why?
No real reason, just made this side project as a challenge... 

## Usage
- Global import (same as `source`ing the module). Note that the `*` **MUST** be enclosed in **quotes** to prevent shell globbing expansion:
```Python
from test.lib import "*"
```

- Selective import (only a specific subset of variables/functions):
```Python
from test.lib import function_name, variable_name
```

- Namespaced import (variables/functions will be available as `MyNamespace.{variable_name/function_name}`):
```Python
from test.lib import function_name, variable_name as MyNamespace
```
