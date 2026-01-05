; The "01_stars.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program prints a character with a new line digraph.
;
; From the "00_hello.asm" file:
; > In assembly language, a symbol is a human‑readable name that represents
; > a memory address, constant value or code location known to the assembler.
; > It’s the assembly‑level equivalent of a “variable name” or “label” in higher‑level languages.
; > Examples:
; > - `var` means the address that is accessible via the var name;
; > - `[var]` means the value at the addres of the var symbol.

; (symbolic) constants
; --- for system calls
stdout_fd equ 1  ; fd 1 (file descriptor for the stdout)
sys_write equ 1  ; write
sys_exit equ 60  ; exit
; --- for "business" logic
char equ '*'     ; character to print on a line (actually ASCII int code)
nlines equ 1     ; the number of lines to print (shouldn't exceed 1 byte)

; Constants are good to be validated.
; Preprocessor directives are handy here because:
; - they are compile-time checks,
; - zero (!) runtime overhead -> no need to run and then check.

; validate nlines
%if nlines < 0 || nlines > 255  ; || means OR opeprator
    %error "nlines must be in the [0,255] segment"
%endif

; validate char
%assign cval char  ; val = ASCII code of char (e.g., '*' → 42)
%if cval < 0 || cval > 127
    %error "char must be a valid ASCII character (0-127)"
%endif

section .bss
    buffer: resb 64  ; `res`erve 64 `b`ytes for a buffer
    bufsiz: resb 1   ; 1 byte as the buffer size
    ; buffer and bufsiz are labels and each represents a memory address.

section .text
    global _start

_start:
    mov al, char
    ; rax = 64-bit register -> 63...31...0 bits
    ; eax = 32-bit -> 31...0 bits (part of rax)
    ; ax = 16-bit version -> 15...0 bits (part of eax)
    ; ax = ah (high = 15..8 bits) and al (low = 7...0 bits)
    ; al = 8 bits, so an ASCII char will fit!
    mov byte [bufsiz], 2
    ; The `[var]` syntax means memory derefencing,
    ; which means "don't use the address var, but the value at it".
    mov [buffer], al  ; [buffer] (== buffer[0]) <- al
    mov byte [buffer + 1], 0xA
    ; [buffer + 1] == buffer[1] == buffer (start) + 1 byte shift
    ; 0xA = 10 = '\n' (LF = line feed)
    ; Here, byte (after the MOV) is crucial,
    ; without -> error: operation size not specified.
    ; For the `mov [buffer], al` the byte specifier is redundant,
    ; because NASM "understands" that AL is a 1-byte register already.

    ; print the content of the buffer
    mov rax, sys_write
    mov rdi, stdout_fd
    mov rsi, buffer
    mov rdx, [bufsiz]
    ; If the `mov rdx, bufsiz` had been written,
    ; then not the value of the bufsiz would have been used,
    ; but the address itself because bufsiz is a label!
    syscall

    ; exit(0) the program
    mov rax, sys_exit
    mov rdi, 0
    syscall
