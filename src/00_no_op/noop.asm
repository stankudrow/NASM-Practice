; The "noop.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program:
; - is designed for the 64-bit CPUs or just x64;
; - is written for the Linux/BSD operating systems;
; - does no operation, therefore, no op;
; - is good to be launched via the `make run` command (just for convenience).
;
; Architecture families for Intel processors:
; - 64-bit = x64 (first, AMD64 with Athlon 64, then adopted by Intel as Intel 64, so x86_64);
; - 32-bit = x86 (x86_32) or IA-32 (Intel Architecture) (Intel 80386 model intro);
; - 16-bit = x86 (8086 -> ... -> 80286 models), or IA, or pre-IA-32;
;
; The numbers above (XX-bit) define the size of a (machine) word.
; A (machine) word is a unit of data a CPU can process natively in a single instruction cycle.
; Historically, a word refers to the size of 16 bits, so:
; - 32-bit word is a double word (dword);
; - 64-bit word is a quadword (qword).
;
; The word size limits the maximum addressable memory as `2**(word_size)`, so:
; - 16-bit = 2**16 -> 64KB;
; - 32-bit = 2**32 -> 4GB;
; - 64-bit = 2**64 -> 16 EB (exabytes, theoretical).
;
; A CPU has internal memory storage locations, or registers.
; The register covered here:
; - RAX (Accumulator) -> originally for arithmetic;
; - RDI (Destination Index) -> destination data address (mostly string/memory ops).
;
; For x64, the above registers have the R (register) prefix.
; For x86_32 systems the prefix is E (extended),
; because they are extended versions of their 16-bit AX and DI variants.
;
; A crucial concept in Assembly language is "symbol".
; A symbol is a human‑readable name that represents:
; - a memory address (location/region);
; - a constant value -> symbolic constant;
; - code location (in a source file).
;
; Assembly language does not have variables like in high-level languages (C, Python etc.).
; Instead, it operates with symbols which have two major subsets:
; - (symbolic) constants -> literals or pure values as they are (mostly no memory addresses);
; - labels -> names associated with memory addresses.
;
; Kinds of labels (roughly variables) by scope/visibility:
; - global:
;   - visible across multiple source files (translation units);
;   - external linkage (other files can reference them via `extern`);
; - static:
;   - accessible in a source file where are defined (file-local);
;   - internal linkage, i.e., cannot be referenced from other files.
;
; Typically, a program has sections (segments) that organise code and data.
; The core sections are:
; - `.text`:
;   - holds executable instructions (code);
;   - executable (CPU can jump to it and process);
;   - typically read-only (design's and security's sakes);
;
; - `.data`:
;   - stores explicitly initialised variables (non-zero values);
;   - embedded in executable (increases file size);
;   - loaded into memory as-is;
;   - writable;
;
; - `.bss`:
;   - for uninitialised/zero-initialised global/static variables;
;   - originally "Block Started by Symbol";
;   - BSS varaibles are zeroed by OS/loader at program startup;
;   - only the BSS size itself is recorded in executable;
;   - efficiency: saves disk space (no zero bytes in binary);
;   - writable;
;
;   > Why "Block Started by Symbol"?
;     * "Block" -> a contiguous memory region;
;     * "Symbol" -> a label that marks the start of the "Block".
;     * also "Block Storage Segment" or "Blank Static Storage"
;
; Instructions in this program:
; - MOV -> move (copy) data from a source to destination:
;   - syntax: `mov destination, source`;
;   - means `destination = source`;
;   - the `destination` can be a register or a memory address;
;   - the `source` can be a register, an address, or just an immediate value;
;   - both operands cannot be memory locations -> `mov [mem1], [mem2]` is wrong;
;   - operand sizes must match -> word with double word is wrong;
;   - examples:
;     - `mov rax, 2` - store 2 in the RAX
;     - `mov rdi, buffer` - store buffer label (=address) in the RDI
;

; The `equ` assembler directive stands for equate and defines a constant.
exit_syscall    equ 60  ; `exit` syscall code (Linux/BSD)
success_retcode equ 0   ; `exit(0)` means "quit normally"

; section .bss  ; no need for this segment yet

; section .data  ; no need this segment yet

section .text  ; code
    global _start
    ; The `global` directive makes the `_start` label global.
    ; It means that `_start` will be visible outside the object file.
    ; It must be global because it is meant to be the program main entry point.
    ; The `_start` name is default for the "ld" linker.

_start:
    ; --- `exit(status_code)` syscall ---
    ; ABI (Application binary interface) for `exit(code)` system call:
    ; - RAX -> system call integer code (60 = exit);
    ; - RDI -> the first and sole argument for the `exit`.
    mov rax, exit_syscall
    mov rdi, success_retcode
    syscall  ; invoke the `exit(0)` syscall (terminate the process/program)

; Feel free to read some `man 2 syscalls` pages.

; References:
; * [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
; * [Sections in ASM programs](https://medium.com/iqube-kct/know-what-is-bss-text-data-memory-segments-of-an-executable-file-in-embedded-systems-6158d92aa519)
; * [What is `global _start`?](https://stackoverflow.com/questions/17898989/what-is-global-start-in-assembly-language)
