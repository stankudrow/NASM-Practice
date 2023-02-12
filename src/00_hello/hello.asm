;hello.asm [NASM] program

; The .data section is used for initialised data.
section .data
    msg db "Hello!", 0xa
    ; msg is the a variable (its name)
    ; db is a type directive (byte).
    ; 0xa = 10 = \n is the ASCII code for a new line.
    ; The comma `,` concatenates (glues together) successive data.
    ; So, "Hello!", 0xa represents "Hello!\n".
    len equ $ - msg
    ; $ is the address of the current address according to the assembler.
    ; Here, $ points at the position after the 0xa byte.
    ; The new line in the code (<Enter>) is ignored, not that one in msg (0xa).
    ; The msg name has the address according to the assembler.
    ; So, the expression `$ - msg` is like `here (the current address) - msg (the address of msg)`.
    ; We can "textualise" it as follows (addresses are chosen arbitrarily):
    ; data:     H e l l o ! 0xa 
    ; indices:  2 3 4 5 6 7 8   9
    ; So, msg points to the address 2 (H), $ to 9 (the position immediately after the 0xa).
    ; Subtracting the addresses, we get the distance between them, which is 7.
    ; EQU evaluates the right hand side `$ - msg` to a constant value `7`.


; BSS = Block Started by Symbol.
; The `.bss` section is used for uninitialised variables.
; At the startup, the variables will be assigned with zeros.
section .bss

; The section `.text` holds the code instructions.
section .text
    global _start
    ; The `global` directive adds the `_start` symbol into an object file.
    ; It is the [main] entry point (where the program begins) for linker (`ld` program).
    ; The name `_start` is the default symbol for linker (`ld`).

_start:  ; the entry point for linker (ld)
    mov edx, len    ; move the length of the `msg` string into the Extended Data register.
    mov ecx, msg    ; move the string (address) into the Extended Counter register.
    mov ebx, 1      ; move the file descriptor 1 (stdout) into the Extended Base register.
    mov eax, 4      ; move the system call 4 (sys_write) into the Extended Accumulator register.
    int 0x80        ; interrupt number -> call kernel
    mov eax, 1      ; system call number 1 (sys_exit)
    int 0x80

; How to run the progrm?
;
; 0. System (see README.md): Ubuntu LTS 22.04.1, x64, AMD Ryzen 5 3500u;
; 1. `nasm -f elf64 00_hello.asm -o hello.o` -> an object file `hello.o` is created;
; 2. `ld -o hello.out hello.o` -> an executable file `hello.out` is "linked" from the `hello.o` file.
; 3. `./hello.out` -> Hello!
;
; Notes
; `-f elf64` is the Executable and Linkable Format for a 64 bit Linux architecture.


; References:
; * [Tutorials Point Assembly Tutorial](https://www.tutorialspoint.com/assembly_programming/assembly_basic_syntax.htm)
; * [Ravesli Assembler Tutorial](https://ravesli.com/assembler-bazovyj-sintaksis/)
; * [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
; * [Sections in ASM programs](https://medium.com/iqube-kct/know-what-is-bss-text-data-memory-segments-of-an-executable-file-in-embedded-systems-6158d92aa519)
; * [How does $ work in NASM, exactly?](https://stackoverflow.com/questions/47494744/how-does-work-in-nasm-exactly)
; * [What is `global _start`?](https://stackoverflow.com/questions/17898989/what-is-global-start-in-assembly-language)