# Design of the hashmap


The `_create_hashmap` function is responsible to reserve the needed space on the heap and internally adds 8 more bytes, to accomodate two 32bit integers containing the amount of elements, and the size per element.

Thus the C-equivalent structure would look like:





