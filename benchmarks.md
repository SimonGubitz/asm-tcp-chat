# Benchmarks


## Overview

This should be an overview over the entire server, how many connections in the group chat are possible concurrently, how many message/s are possible, and 



***Format of each benchmark***
```
## Methodology:

describe the compilation flags of nasm and wether the debug symbols are included

{description}


## Results


## Explaining the results

```


## TODO (what to benchmark):

- benchmark the protocol
    - with and without 8byte aligned padding
    - with and without little-endian
- benchmark against a similar C implementation
- benchmark against a C implementation without `epoll`

