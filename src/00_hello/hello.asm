; The "hello.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; Consider `make run` command to compile or run the program.
;
; Common categories of CPU architectures (Intel architecture families):
; - 64-bit = x64 (first, AMD64 with Athlon 64, then adopted by Intel as Intel 64, so x86_64);
; - 32-bit = x86 (x86_32) or IA-32 (Intel Architecture) (introduced with Intel 80386 model);
; - 16-bit = x86 (8086 -> ... -> 80286 models), or IA, or pre-IA-32;
;
; A unit of data a CPU can process natively in a single instruction cycle is a machine word (or simply word).
; For x86_16 family, a word is a 16-bit portion and 32-bit unit for IA-32.
; For historical reasons (from the perspective of 16-bit CPUs):
; - a 32-bit word can be labeled as a double word (dword);
; - a 64-bit word can be refferred to as a quadword (qword).
;
; Also, word size limits the maximum addressable memory as `2**(word_size)`, so:
; - 16-bit = 2**16 -> 64KB;
; - 32-bit = 2**32 -> 4GB;
; - 64-bit = 2**64 -> 16 EB (exabytes, theoretical).
;
; A CPU has internal memory storage locations, or registers.
; Some general-purpose registers (for 16-bit CPU versions):
; - data registers:
;   - AX (accumulator) -> arithmetic, I/O, return codes etc.;
;   - BX (base) -> base addressing ???? (arrays???);
;   - CX (counter) -> loop counters and shifts;
;   - DX (data) -> I/O data or extended precision (e.g., 32-bit multiply/divide ops);
; - index registers:
;   - SI (source index) -> source data address (mostly string/memory ops);
;   - DI (destination index) -> destination data address (mostly string/memory ops);
; - pointer registers:
;   - IP (instruction pointer) -> the address of the next instruction to be executed.
;
; The above registers come with the E (32-bit) or R (64-bit) prefix, e.g. EAX or RAX.
; Since this program is written for x64 Linux/BSD, R registers may be encountered
; unless their narrower variants are more suitable (compatibility matters).
;
; In assembly language, a symbol is a human‑readable name that represents
; a memory address, constant value or code location known to the assembler.
; It’s the assembly‑level equivalent of a “variable name” or “label” in higher‑level languages.
; Examples:
; - `var` means the address that is accessible via the var name (like pointer);
; - `[var]` means the value at the address of the var symbol (dereferencing a pointer).
;
; Assembly language does not have variables like in high-level languages (C, Python etc.).
; Instead, it operates with symbols which have two major subsets:
; - (symbolic) constants -> literals or pure values as they are (mostly no memory addresses);
; - labels -> names associated with memory addresses.
;
; So, a lable is a user-defined symbol in Assembly source code.
; It referes to a memory address and points to code or data.
; The syntax for label definition is `label_name:` (with colon).
; Constants are also user-defined symbols in Assembly source code.
;
; Kinds of labels (roughly variables) by scope/visibility:
; - global:
;   - visible across multiple source files (translation units);
;   - external linkage (other files can reference them via `extern`);
; - static:
;   - accessible in a source file where are defined (file-local);
;   - internal linkage, i.e., cannot be referenced from other files.
;
; Typically, a program has sections (segments) that organise code and data in memory.
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

; The `equ` assembler directive stands for equate and defines a constant.
stdout_fd equ 1   ; file descriptor 1, or standard output stream (stdout)
sys_write equ 1   ; system call (syscall) with code 1 or `write`
sys_exit  equ 60  ; `exit` syscall

; section .bss  ; no need fo this segment yet

section .data
    msg: db 'Hello!', 0xa  ; "Hello" string terminated with `\n` (10 or 0XA code)
    ; `msg` is a data label.
    ; `db` (define byte) is the assembly directive meaning "store one or more 1-byte values", not just "define 1-byte only".
    ; 0xA (hex) = 10 (dec) = '\n' (ASCII) = new line = line feed (LF).
    ; Comma concatenates: `"Hello", 0xa` means `"Hello!\n"`.

    msg_len equ $ - msg
    ; The msg points at the beginning of the region in memory.
    ; The $ is a built-in assembler symbol (location counter) that represents:
    ; * the current output address in the section being assembled;
    ; * the address where the next instruction/data byte will be placed;
    ; Here, $ points to the position immediately after the 0xa byte,
    ; which is the next free address for further assemblying.
    ; So, the expression `$ - msg` computes the region/string length..


section .text
    global _start  ; this directive makes the `_start` label global.

; The _start label is a code location label.
; This label is special and marks the [main] entry point.
; The _start label must be global, i.e., be visible outside the object file.
; The `_start` name is default for the ld linker.
_start:
    ; --- `write(fd, buffer, size)` syscall ---
    ; MOV RAX, 1 means "move the value 1 into the RAX register"
    mov rax, sys_write  ; 1 is the number for the `write` syscall (Linux/BSD)
    mov rdi, stdout_fd  ; argument 1 -> `write(1, ...)` where 1 is the file descriptor 1 (stdout)
    mov rsi, msg        ; argument 2 -> pointer to a buffer (here the string at the msg address)
    mov rdx, msg_len    ; argument 3 -> data (here, "Hello\n" string) length
    syscall             ; invoke the `write(1, msg, msg_len)` syscall (write data to the stdout)

    ; --- `exit(status_code)` syscall ---
    mov rax, sys_exit   ; 60 is a number for the `exit` syscall (Linux/BSD)
    mov rdi, 0          ; argument 0 -> success return code/status
    syscall             ; invoke the `exit(0)` syscall (terminate the process/program)

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
