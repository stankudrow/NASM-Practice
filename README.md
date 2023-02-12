# NASM-Practice

My educational track on Assembly language with the Netwide Assembler [NASM].

## What is NASM?

The Netwide Assembler, NASM, is an 80x86 and x86-64 assembler ([source](https://nasm.us/doc/nasmdoc1.html#section-1.1)).

## Running NASM

To assemble a file, you run a command of the form

```shell
nasm -f <format> <filename> [-o <output>]
```

Examples:

* assembling `file.asm` into an ELF ([Executable and Linkable Format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)) object file `file.o`:

```shell
nasm -f elf64 file.asm
```

* assembling a file with an output file name and a listing file name:

```shell
nasm -f elf64 afile.asm -o ofile.o -l lfile.lst
```

Please refer to [NASM docs](https://nasm.us/doc/nasmdoc2.html) for more details.

## About the system

* Processor: AMD Ryzen 5 3500u;
* OS Name: Ubuntu 22.04.1 LTS;
* OS Type: 64-bit.

## References

* [NASM official docs](https://nasm.us/doc/nasmdoc0.html)
* [Tutorials Point - Assembly Programming](https://www.tutorialspoint.com/assembly_programming/)
* [Ravesli - Uroki Assemblera](https://ravesli.com/uroki-assemblera/)
* [Introduction to NASM (pdf)](https://nasmnitc.github.io/NASM%20Manual.pdf)
* [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
