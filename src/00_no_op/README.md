# First Program

The first target program is the "noop.asm" source file.
Makefile, for simplicity's sake, is written to build and run only Assembly code. Use `make run` to "see" the result.

The current directory contains the C version of the "noop.asm" program. Makefile does not have rules to manage it, yet you can play with compiler (`gcc` or `clang`), for instance with GNU tools:

1. `gcc -E noop.c -o noop.i` - preprocessing done -> comments stripped, macros expanded.
2. `gcc -S noop.i -o noop.s` - Assembly code for target architecture generated.
3. `as noop.s -o noop.o` - object file generated (`as` - portable GNU assembler).
4. `ld -o noop.out ./noop.o` will lead to "ld: warning: cannot find entry symbol _start; defaulting to 0000000000401000" because no _start in "noop.c" -> so `gcc` will do linkage: `gcc -o noop.out noop.o`.
5. `./noop.out` - run the program.

All these steps could be combined into a single command: `gcc -o noop.out noop.c`.
