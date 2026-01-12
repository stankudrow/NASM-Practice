; The "00_print_char.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program prints a character with a new line digraph.
;
; In assembly language, a symbol is a human‑readable name (identifier) that represents:
; - a memory address (labels/symbols);
; - a constant (literal) value (symbolic constants).
; The main purpose of symbols is to organise code/data in a program.
; An assembler associates names with values during program translation.
; Labels and constants do not appear in the final executable code.
; because it is convenient to deal with names than with address values.
;
; Suppose we have a label `my_label:` which has a value (assciated address).
; Referring to it as `my_label` is operating with the associated memory address.
; A label name in brackets, `[my_label]` is the value at the address of the `my_label` symbol.
; So, the `[var]` syntax is about dereferencing the label (which is like a pointer).
;
; The "../00_hello/hello.asm" file has notes about the MOV instruction.
; Here you can find similar ecamples:
; - `mov rax, [mem1]` -> store the value from the mem1 region into the RAX
; - `mov [mem2], 3` -> store the 3 value at the mem2 address
;
; Caution!
; `mov rbx, label` -> rbx holds the address of the label as a value.
; `mov rbx, [label]` -> rbx stores the value fetched from the label address.
;

; (symbolic) constants
; --- for system calls
stdout_fd equ 1         ; stdout (file descriptor 1)
sys_write equ 1         ; write syscall
sys_exit equ  60        ; exit syscall
sys_exit_success equ 0  ; success return code
; --- for "business" logic
CHAR equ '*'       ; character to print (actually an ASCII code)
BUFFER_SIZE equ 2  ; buffer size: CHAR + '\n'

; Constants are good to be validated.
; Preprocessor directives are handy here because:
; - they are compile-time checks,
; - zero (!) runtime overhead -> no need to run and then check.
; Preprocessor directives start with a percent `%` character.

; validate char
%if CHAR < 0 || CHAR > 255  ; || means the OR operator
    %error "char must be a valid ASCII byte (0-255)"
%endif

section .bss
    buffer: resb 2  ; `res`erve 2 `b`ytes for a buffer

section .text
    global _start

_start:
    mov al, CHAR
    ; rax = 64-bit register -> 63...31...0 bits
    ; eax = 32-bit -> 31...0 bits (part of rax)
    ; ax = 16-bit version -> 15...0 bits (part of eax)
    ; ax = ah (high = 15..8 bits) and al (low = 7...0 bits)
    ; al = 8 bits, so an ASCII char will fit!

    mov [buffer], al  ; [buffer] (== buffer[0]) <- al
    mov byte [buffer + 1], 0xA
    ; [buffer + 1] == buffer[1] == buffer (start) + 1 byte shift
    ; Here, byte (after the MOV) is crucial,
    ; without it an error occurs: operation size not specified.
    ; For the `mov [buffer], al` the byte specifier is redundant,
    ; because NASM "understands" that AL is a 1-byte register already.

    ; print the content of the buffer
    mov rax, sys_write
    mov rdi, stdout_fd
    mov rsi, buffer
    mov rdx, BUFFER_SIZE
    syscall

    ; exit the program
    mov rax, sys_exit
    mov rdi, sys_exit_success
    syscall
