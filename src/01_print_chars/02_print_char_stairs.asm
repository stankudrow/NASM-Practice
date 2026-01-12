; The "02_print_stairs.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program prints stairs like this:
; *
; **
; ***
; ... and so forth.
;
; New instructions in this program:
; - ADD -> addition:
;   - syntax: `add destination, source`
;   - means `destination = destination + source`;
;   - both operands must be the same size
;   - both operands cannot be memory locations;
;   - the source is read-only, the destination is modified;
; - SUB -> subtraction:
;   - syntax: `add destination, source`
;   - means `destination = destination + source`;
;   - both operands must be the same size
;   - both operands cannot be memory locations;
;   - the source is read-only, the destination is modified;
; - CMP -> compare two operands:
;   - syntax: `cmp operand1, operand2`;
;   - both operands must be the same size
;   - both operands cannot be memory locations;
;   - computes `a - b` internally and:
;     - leaves operands unchanged;
;     - discards the result;
;     - updates some FLAGS: ZF, SF, OF etc.
; - JLE -> "Jump if Less or Equal":
;   - syntax: `jle label`;
;   - signed comparison only (JLE interprets operands as signed integers);
;   - checks the following flags and jumps if:
;     - ZF=1 (result=0) -> equal;
;     - SF (sign) != OF (overflow) -> negative -> less than;
;
; This program can be more efficient, can you guess how?
;

CHAR equ '*'
%if CHAR < 0 || CHAR > 255
    %error "char must be a valid ASCII byte (0-255)"
%endif

NLINES equ 10
%if NLINES < 0 || NLINES > 100
    %error "the number of lines must be not greater than 100"
%endif

BUFSIZE equ NLINES + 1
NEWLINE equ 0xA  ; do not use '\n' here because it is a string!

stdout_fd equ 1
sys_write equ 1
sys_exit equ 60

section .bss
    buf: resb BUFSIZE

section .text
    global _start

_start:
    mov r8, NLINES  ; line counter
    test r8, r8  ; NLINES = 0 -> ZF=1
    jz .quit

    mov r8, 1    ; starting with the first line
    mov rbx, buf  ; rbx is a temporary storage for the rdi

.loop:
    mov rdi, rbx
    mov byte [rdi], CHAR  ; write the CHAR
    inc rdi  ; move the current position pointer forward
    mov byte [rdi], NEWLINE  ; add a new line char
    mov rbx, rdi  ; save the current position

    ; For the next iteration,
    ; the rbx (future rdi) already points
    ; to the current poistion that is `\n'
    ; which will be overwritten with the CHAR
    ; and then appended with the NEWLINE

.print_line:
    mov rax, sys_write
    mov rdi, stdout_fd
    mov rsi, buf
    mov rdx, rbx  ; rdx = rbx = rdi -> (buf + i), i>=0
    sub rdx, rsi  ; rdx = rdi - rsi (=buf) = i -> buffer length
    add rdx, 1  ; account the new line -> INC is also possible
    syscall

    ; check if loop or quit
    add r8, 1  ; row++ -> also `inc r8`
    cmp r8, NLINES
    jle .loop

.quit:
    mov rax, sys_exit
    mov rdi, 0
    syscall
