; The "noop.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program:
; - is written for Linux operating systems and 64-bit (x64) CPUs;
; - does no operation, therefore, no op...actually it does :)
;
; Architecture families (for Intel processors):
; - 64-bit = x64 (first, AMD64 with Athlon 64, then adopted by Intel as Intel 64, so x86_64)
; - 32-bit = x86 (x86_32) or IA-32 (Intel Architecture) (Intel 80386 model intro)
; - 16-bit = x86 (8086 -> ... -> 80286 models), or IA, or pre-IA-32
;
; The numbers above (XX-bit) define the size of a (machine) word.
; A (machine) word is a unit of data that a CPU can process natively in a single instruction cycle.
; The word size limits the maximum addressable memory as `2**(word_size)` of RAM (random-access memory)
; Historically:
; - a 16-bit machine word is a word -> 2**16 -> 64KB;
; - a 32-bit (machine) word is a double word (dword) -> 2**32 -> 4GB;
; - a 64-bit (machine) word is a quadword (qword) -> 16 EB (exabytes, theoretical).
;
; Assembly language uses mnemonics - short, human‑readable symbolic codes.
; Mnemonics represent (basic) machine‑level instructions
; and it is easier to operate with them than raw binary codes.
;
; A CPU has internal memory storage locations, or registers.
; In Assembly, mnemonics for registers start with the prefix:
; - R (register) for x64, e.g. RAX -> [63, 62, ..., 1, 0] bits;
; - E (extended) for x86_32, e.g. EAX -> [31, 30, ..., 1, 0] bits.
; For "x16" no prefix is used, so it is just the AX register.
; Potentially interesting details about the AX register:
; - X stands for "extended";
; - AX is "extended" because it is composed of:
;   - AH (high) part -> [15, 14, ..., 9, 8] bits;
;   - AL (low) part -> [8, 7, ..., 1, 0] bits.
;
; The registers covered here:
; - RAX (Accumulator) -> general-purpose register:
;   - Primary accumulator -> general storage for values.
; - RDI (Destination Index):
;   - Stores destination data address (mostly string/memory ops)
;   - RDI (x64) > ESI (x32 > SI ("x16").
;
; A system call (syscall) is like a function that requests "a favour" to OS.
;
; Abundance of comments in Assembly programs is vital.
;

; The `equ` assembler directive stands for "equate" and defines a constant.
EXIT_SYSCALL    equ 60  ; `exit` system call code (Linux/BSD)
SUCCESS_RETCODE equ 0   ; `exit(0)` means "quit normally"

; The actual code is written in the `.text` section
section .text
    global _start  ; makes the _start label default
    ; The `_start` name is default for the "ld" linker.
    ; This is the entry point for the program and it must be so for now.

_start:
    ; --- `exit(status_code)` syscall ---
    ; ABI (Application binary interface) for the `exit(code)` syscall:
    ; - RAX -> system call integer code (60 = exit);
    ; - RDI -> the first and sole argument for the `exit`.
    ; -----------------------------------
    mov rax, EXIT_SYSCALL
    mov rdi, SUCCESS_RETCODE
    syscall  ; invoke the `exit(0)` syscall (terminate)

; Feel free to read some `man 2 syscalls` pages.

; References:
; * [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
; * [Sections in ASM programs](https://medium.com/iqube-kct/know-what-is-bss-text-data-memory-segments-of-an-executable-file-in-embedded-systems-6158d92aa519)
; * [What is `global _start`?](https://stackoverflow.com/questions/17898989/what-is-global-start-in-assembly-language)
