; The "00_putstr.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program just prints "Hello" string.
;
; In NASM, the `$` symbol is a special built‑in operator
; that evaluates to the current assembly address (offset)
; within the current section at the point where it’s used.
;
; Key properties:
; - Current address:
;   - $ always holds the address where the next byte will be placed in the current section.
;   - It advances automatically as NASM emits code/data.
; - Section‑local:
;   - Each section (.text, .data, etc.) has its own $ counter.
;   - When you switch sections, $ resets to the section’s base address.
; - Compile‑time only:
;   - $ is resolved during assembly (not at runtime).
;   - $ is read‑only.
; - Not a label:
;   - You can’t jump to $ (e.g., `jmp $` is invalid).
;   - A numeric value, not a symbol.
;


stdout_fd equ 1      ; file descriptor 1 -> standard output stream (stdout)
sys_write equ 1      ; `write` syscall
sys_exit  equ 60     ; `exit` syscall
sys_exit_ok equ 0    ; success return code for `exit`
sys_exit_fail equ 1  ; error return code for `exit`

NEWLINE equ 0xA   ; do not define it as '\n' which is a two-byte string ('\' and 'n')

section .bss  ; can be declared, but be blank anyway

section .data
    ; When NASM enters this `.data` section, `$` is reset to 0 (the start of `.data`).

    msg: db 'Hello!', NEWLINE  ; the comma operator does concatenation -> 'Hello!\n'
    ; `msg` is a data label -> points to a memory region.
    ; `msg` is defined to store bytes via the `db` (define byte) directive.
    ; `db` is about "store one or more 1-byte values", not just "define 1-byte only".
    ; Relatively (!) to this section the address of `msg` is zero.
    ; NASM encoded the previous line to a byte sequence:
    ; 'H', 'e', 'l', 'l', 'o', '!', 0xA -> 7 bytes.
    ; Since this line was defined at the start of `.data` section,
    ; and the address of `msg` in `.data` is 0 (again, relatively),
    ; then, `$ = msg + 7 = 0 + 7 = 7` - the offset of 7 bytes.

    msg_len equ $ - msg  ; 7 - 0 = 7 = buffer length


section .text
    global main
    ; Not only `_start` default label can be used as an entry point,
    ; yet the linker ("ld" in my case) must be instructed about this change,
    ; otherwise: "ld: warning: cannot find entry symbol _start; defaulting to 0000000000401000".
    ; See the Makefile alongside this program.

; It is important that this label shouldn't be prefix with a dot.
; If it were named as ".main", then we would get the warning:
; "ld: warning: cannot find entry symbol _start; defaulting to 0000000000401000".
; On Linux/ELF, symbols starting with `.` are often treated as:
; - local labels which are not meant to be valid entry points;
; - debugging or metadata symbols -> again, internal stuff.
; The `nm hello.o | grep main` will emit `0000000000000000 T main` -> OK! (T = symbol in the `.text` section).
main:
    ; write data
    mov rax, sys_write
    mov rdi, stdout_fd
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; test write syscall
    cmp rax, 0
    jl .error

    ; quit normally
    mov rax, sys_exit
    mov rdi, sys_exit_ok
    syscall

.error:
    mov rax, sys_exit
    mov rdi, sys_exit_fail
    syscall

; Feel free to read some `man 2 syscalls` pages.

; References:
; * [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
; * [How does $ work in NASM, exactly?](https://stackoverflow.com/questions/47494744/how-does-work-in-nasm-exactly)
; * [How statically linked programs run on Linux](https://eli.thegreenplace.net/2012/08/13/how-statically-linked-programs-run-on-linux)
