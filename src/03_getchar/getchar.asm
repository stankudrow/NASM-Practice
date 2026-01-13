; The "01_putchars.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program reads a char from the standard input stream (stdin).
;
; The instructions covered here:
; - JE -> Jump if Equal:
;   - alias for `JZ` -> checks ZF=1
; - JNE -> Jump if Not Equal:
;   - alias for `JNZ` -> checks ZF=0
; - JMP -> unconditional jump -> just jump (goto)
;

stdin_fd equ 0
stdout_fd equ 1
sys_read equ 0
sys_write equ 1
sys_exit equ 60

BUFFER_SIZE equ 64
; try to type more than 64 chars (with NEWLINE):
; 64 will be read into the buffer
; and the tail will appear in the shell
; after leaving this program

NEWLINE equ 0xA
READ_SIZE equ 2 ; 1 byte for input + NEWLINE

section .data  ; section, not a label -> no colon here!
    prompt db "Please enter a character: "
    prompt_len equ $ - prompt

section .bss  ; section, not a label -> no colon here!
    buffer: resb BUFFER_SIZE  ; the colon is optional in this specific context

section .text
    global welcome

; Without dot (`.`) -> can be visible for a linker if this label is global.
; Labels with dots are considered file-local and are not recorded into the symbol-table.
welcome:
    ; normal flow

    ; print prompt
    mov rax, sys_write
    mov rdi, stdout_fd
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; check write
    cmp rax, 0
    jl .error

    ; read stdin
    mov rax, sys_read
    mov rdi, stdin_fd
    mov rsi, buffer
    mov rdx, BUFFER_SIZE
    syscall

    ; check read
    cmp rax, 0
    jl .error       ; RAX < 0
    je .eof         ; RAX == 0

    ; if NEWLINE was already read
    cmp byte [buffer], NEWLINE
    jne .add_newline
    ; else, only 1 byte (NEWLINE) to write
    mov rdx, 1
    jmp .write

.add_newline:
    mov rdx, READ_SIZE
    ; overwrite the second character anyway -> if more are given
    mov byte [buffer + 1], NEWLINE

.write:
    mov rax, sys_write
    mov rdi, stdout_fd
    mov rsi, buffer
    ; RDX is already set
    syscall

.quit:
    mov rax, sys_exit
    mov rdi, 0
    syscall

; end of normal flow -> other branches

.error:
    mov rdi, rax
    neg rdi  ; negate error code and pass it to `exit`
    mov rax, sys_exit
    syscall

.eof:
    mov rax, sys_exit
    mov rdi, 2
    syscall
