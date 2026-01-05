; The "hello.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; Some general-purpose registers (for 16-bit CPU versions):
; - AX (accumulator) -> originally for arithmetic;
; - BX (base) -> originally for base addressing (e.g. array bases);
; - CX (counter) -> originally for loop counters (LOOP instruction) and shifts;
; - DX (data) -> originally for I/O data or extended precision (e.g., 32-bit multiply/divide);
; - SI (source index) -> points to source data (e.g., string/memory ops);
; - DI (destination index) -> points to destination data (e.g., string/memory ops);
; - SP (stack pointer) -> always points to the top of the stack;
; - BP (base pointer) -> typically points to the base of the current function's stack frame.
;
; The above registers come with:
; - the E prefix for 32-bit (x86) versions (introduced with the Intel 80386);
; - the R prefix for 64-bit (x64) versions (introduced with AMD64/x86_64).
;
; In assembly language, a symbol is a human‑readable name that represents
; a memory address, constant value or code location known to the assembler.
; It’s the assembly‑level equivalent of a “variable name” or “label” in higher‑level languages.
; Examples:
; - `var` means the address that is accessible via the var name;
; - `[var]` means the value at the addres of the var symbol.
;
; Kinds of labels (scope/visibility):
; - global:
;   - visible across multiple source files (translation units);
;   - have external linkage (other files can reference them via `extern`);
;   - persistent lifetime from program start to end;
; - static:
;   - accessible in a source file where are defined (file-local);
;   - internal linkage, i.e., cannot be referenced from other files.
;
; Typically, a program has sections (segments) that organise code and data in memory.
; The core sections are:
; - `.bss`:
;   - Holds uninitialized/zero-initialized global/static variables;
;   - These varaibles are zeroed by OS/loader at program startup;
;   - Only the BSS size is recorded in executable, no data bytes;
;   - Writable (can be modified at runtime);
;   - BSS = "Block Started by Symbol":
;     * "Block": contiguous memory region;
;     * "Symbol": label marking block start (e.g., `my_var BSS 10` in early assemblers).
;   - Efficiency: saves disk space (no zero bytes in binary).
;
; - `.data`:
;   - Stores explicitly initialized variables (non-zero values);
;   - Data embedded in executable (increases file size);
;   - Loaded into memory as-is;
;   - Writable (can be modified by post-initialisations);
;
; - `.text`:
;   - Contains executable machine instructions;
;   - Marked: readable + executable, typically not writable (security);
;   - Default code section in x86/x64;
;   - Read-only: prevents accidental code modification;
;   - Often page-aligned for memory management efficiency.
;
; To run this program, run the `make` command
; or "parcourez" the recipes in the Makefile.


; `equ` (equate) is an assembler directive that defines a symbolic constant.
; `equ` defines a symbol as a constant value (no memory address).
; The values of constants are computed at assembly time, not at run time.
stdout_fd equ 1
sys_write equ 1
sys_exit  equ 60

section .bss
    ; this section is intentionally left blank

section .data
    msg: db 'Hello!', 0xa  ; not zero-terminated by default
    ; `msg` is a data label (memory address representative).
    ; `db` (define byte) is the assembly directive meaning "store one or more 1-byte values", not just "define 1-byte only".
    ; 0xA (hex) = 10 (dec) = '\n' (ASCII) = new line.
    ; Comma concatenates: "Hello", 0xa == "Hello!\n".

    msg_len equ $ - msg
    ; The msg points at the beginning of the region in memory.
    ; The $ is a built-in assembler symbol (location counter) that represents:
    ; * the current output address in the section being assembled;
    ; * the address where the next instruction/data byte will be placed;
    ; Here, $ points to the position immediately after the 0xa byte,
    ; which is the next free address for further assemblying.
    ; So, the expression `$ - msg` computes the region/string length.
    ; ---
    ; `equ` does not increment the value in the $ symbol.


section .text
    global _start
    ; The `global` directive adds the `_start` symbol into an object file.
    ; It is the [main] entry point for a linker program (e.g., ld).
    ; The `_start` name is the default one for the ld linker.

_start:  ; this is a code location label (also an address)
    ; --- system call: write(fd, buf, siz) ---
    mov rax, sys_write  ; 1 is the number for the `write` syscall (Linux/BSD)
    mov rdi, stdout_fd  ; argument 1 -> `write(1, ...)` where 1 is the file descriptor 1 (stdout)
    mov rsi, msg        ; argument 2 -> pointer to a buffer (here the string at the msg)
    mov rdx, msg_len    ; argument 3 length data
    syscall             ; invoke kernel (here, the `write(1, msg, msg_len)` syscall)

    ; --- system call: exit(0) ---
    mov rax, sys_exit   ; 60 is a syscall number for `exit`
    mov rdi, 0          ; argument 0 -> success return code/status
    syscall             ; terminate process (invoke the `exit(0)` syscall)

; Notes concerning system calls.
; ABI (Application binary interface) for `exit(code)` system call:
; - RAX is for system call numbers (1 = write, 60 = exit).
; - RDI is for a number that is the first argument for the syscall in the RAX.
; For the `write(fd, buffer, size)` system call the ABI states that:
; - RSI stores the addres of a buffer (the second argument);
; - RDX holds the size (in bytes) to write (the third argument).
; Also, syscall returns error codes (negative integers) in the RAX.
; Feel free to read some `man 2 syscalls` pages.

; References:
; * [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
; * [Sections in ASM programs](https://medium.com/iqube-kct/know-what-is-bss-text-data-memory-segments-of-an-executable-file-in-embedded-systems-6158d92aa519)
; * [How does $ work in NASM, exactly?](https://stackoverflow.com/questions/47494744/how-does-work-in-nasm-exactly)
; * [What is `global _start`?](https://stackoverflow.com/questions/17898989/what-is-global-start-in-assembly-language)