; The "hello.asm" [NASM] program for x64.
;
; Some general-purpose registers (for 16-bit CPU versions):
; - ax (accumulator) -> originally for arithmetic;
; - bx (base) -> originally for base addressing (e.g. array bases);
; - cx (counter) -> originally for loop counters (LOOP instruction) and shifts;
; - dx (data) -> originally for I/O data or extended precision (e.g., 32-bit multiply/divide);
; - si (source index) -> points to source data (string/memory ops);
; - di (destination index) -> points to destination data (string/memory ops);
; - sp (stack pointer) -> always points to the top of the stack;
; - bp (base pointer) -> typically points to the base of the current function's stack frame.
;
; The above registers come with:
; - the E prefix for 32-bit (x86) versions (introduced with the Intel 80386);
; - the R prefix for 64-bit (x64) versions (introduced with AMD64/x86_64).
;
; Kinds of variables:
; - global:
;   - visible across multiple source files (translation units);
;   - have external linkage (other files can reference them via `extern`);
;   - persistent lifetime from program start to end;
; - static:
;   - accessible in a source file where are defined (file-local);
;   - internal linkage, i.e., cannot be referenced from other files.
;
; Typically, a program has sections (segments) that organise code and data in memory.
; The core sections are `.bss`, `.data` and `.text`.
; Program sections (segments):
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


section .bss
    ; this section is intentionally left blank

section .data
    msg: db 'Hello!', 0xa  ; not zero-terminated by default
    ; `msg` is a label (a name for address).
    ; `db` (define byte) is an assembly directive
    ; which means "store one or more 1-byte values", not just "define 1-byte only".
    ; 0xA (hex) = 10 (dec) = '\n' (ASCII) = new line.
    ; Comma concatenates: "Hello", 0xa == "Hello!\n".

    msg_len equ $ - msg
    ; The msg points at the beginning of the region in memory.
    ; The $ is a built-in assembler symbol (location counter) that represents:
    ; * the current output address in the section being assembled;
    ; * the address where the next instruction/data byte will be placed;
    ; Here, $ points to the position immediately after the 0xa byte,
    ; which is the next free address for further "assemblering".
    ; So, the expression `$ - msg` computes the region/string length.
    ; ---
    ; `equ` (equate) is an assembler directive that defines a symbolic constant.
    ; This value is computed at assembly time, not runtime.
    ; No memory allocation is made -> does not affect the $ value.


section .text
    global _start
    ; The `global` directive adds the `_start` symbol into an object file.
    ; It is the [main] entry point for a linker program.
    ; The name `_start` is the default symbol for the "ld" linker.

_start:
    mov rax, 1        ; syscall number: 1 is write (Linux/BSD)
    mov rdi, 1        ; fd (file descriptor) 1 = stdout
    mov rsi, msg      ; buffer: pointer to the address of "msg"
    mov rdx, msg_len  ; message length data
    syscall           ; invoke kernel (int 0x80 for x86-only)
    ; --- system call: exit(0) ---
    mov rax, 60       ; syscall number: 60 is exit
    mov rdi, 0        ; status: 0 (success)
    syscall           ; terminate process

; References:
; * [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
; * [Sections in ASM programs](https://medium.com/iqube-kct/know-what-is-bss-text-data-memory-segments-of-an-executable-file-in-embedded-systems-6158d92aa519)
; * [How does $ work in NASM, exactly?](https://stackoverflow.com/questions/47494744/how-does-work-in-nasm-exactly)
; * [What is `global _start`?](https://stackoverflow.com/questions/17898989/what-is-global-start-in-assembly-language)