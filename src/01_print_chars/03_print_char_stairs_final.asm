; The "03_print_stairs_final.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program prints stairs like this:
; *
; **
; ***
; ... and so forth.
;
; Features:
; - one `write` system call -> good because calling OS is not free;
; - still one buffer, but with larger size -> not so bad.
;

CHAR equ '*'
%if CHAR < 0 || CHAR > 255
    %error "char must be a valid ASCII byte (0-255)"
%endif

NLINES equ 10
%if NLINES < 0 || NLINES > 100
    %error "the number of lines must be not greater than 100"
%endif

; Math refresher.
; The sum of an arithmetic progression: S = (n * (n + 1)) // 2 (integer division).
; Proof:
; 1. S = 1 + 2     + ... + (n-1) + n -> n terms
; 2. S = n + (n-1) + ... + 2     + 1 -> reversed
; 3. 2S = (1+n) + (1+n) + ... + (n+1) + (n+1) -> still n terms :)
; 4. S = (n * (n+1)) // 2
; Why does this matter?
; line 1: '*\n' -> 2 bytes
; line 2: '**\n' -> 3 bytes
; ...
; line N: N stars + 1 new line
; So, the total buffer size is of 2 components:
; first, stars -> S_1 = (N * (N + 1)) // 2;
; second, new line digraphs: S_2 = N
; total: S = (N * (N + 3)) // 2
BUFSIZE equ (NLINES * (NLINES + 3)) / 2
NEWLINE equ 0xA

stdout_fd equ 1
sys_write equ 1
sys_exit equ 60

section .bss
    buf: resb BUFSIZE

section .text
    global _start

_start:
    mov r8, NLINES
    test r8, r8
    jz .quit

    mov rdi, buf  ; current position pointer
    mov r8, 1     ; current line number

.outer_loop:
    mov r9, r8  ; current line number = number of stars

.inner_loop:
    ; form a star line
    mov byte [rdi], CHAR
    inc rdi
    dec r9
    jnz .inner_loop

    ; add a new line digraph
    mov byte [rdi], NEWLINE
    inc rdi

    ; next line or print them all
    inc r8
    cmp r8, NLINES
    jle .outer_loop

.print_all:
    ; One syscall to print the entire buffer
    mov rax, sys_write
    mov rsi, buf
    mov rdx, rdi  ; RDX = current write pointer
    sub rdx, buf  ; RDX = total bytes written
    mov rdi, stdout_fd  ; now can overwrite
    syscall

.quit:
    mov rax, sys_exit
    mov rdi, 0
    syscall
