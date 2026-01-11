; The "01_print_chars.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program prints a line of character with a new line char.
; Here loops are introduced and flag registers are covered.
;
; A CPU has flag, or status, registers (RFLAGS in 64-bit mode).
; Some commonly used flags are:
; - carry flag (CF) -> unsigned (!) overflow (0xFF + 1 = 0x100 -> carry out);
; - sign flag (SF) -> equals the most significant bit (MSB) of the result (SF=1 -> negative);
; - overflow flag (OF) -> signed (!) overflow (127 + 1 = -128 -> OF=1);
; - zero flag (ZF) -> the result is 0 (1 - 1 = 0 -> ZF=1);
; - ...
; - and some others to be covered later (maybe).
;
; Example:
; - mov ecx, 1  ; the result is 1 -> ZF=0
; - dec ecx  ; decrement ECX -> the result is 0 -> ZF=1
; - inc exc  ; increment ECX -> the result is not 0 -> ZF=0
; DEC/INC (and some other) instructions update the ZF automatically.
;

; (symbolic) constants
; --- for system calls
stdout_fd equ        1   ; stdout (file descriptor 1)
sys_write equ        1   ; write syscall
sys_exit equ         60  ; exit syscall
sys_exit_success equ 0   ; success return code
; --- for "business" logic
CHAR equ        '*'         ; character to print (actually an ASCII code)
NCHARS equ      5           ; the number of chars in a line
BUFFER_SIZE equ NCHARS + 1  ; NCHARS chars + 1 newline byte (0xA)

%if CHAR < 0 || CHAR > 255
    %error "char must be a valid ASCII byte (0-255)"
%endif
%if NCHARS < 0 || NCHARS > 255
    %error "the number of chars must be a valid byte (0-255)"
%endif
%if BUFFER_SIZE < 0 || BUFFER_SIZE > 256
    %error "the buffer can store 255 chars with a new line (in total, 256)"
%endif

section .bss
    buffer: resb BUFFER_SIZE

section .text
    global _start

_start:
    mov cl, NCHARS   ; initialise loop counter
    mov rdi, buffer  ; buffer is a destination

; The following section is "within" the _start label context,
; so is the following `.write_loop` label
; which is a local label belonging to the preceding global label (`_start`).
; This has nothing to do with label scopes or nesting, it is all linear.
.write_loop:
    mov byte [rdi], CHAR  ; write CHAR at the RDI (=buffer here) address -> dereferencing
    inc rdi  ; increment RDI -> move pointer forward (the next address -> no dereferencing)
    dec cl   ; decrement counter
    jnz .write_loop  ; JNZ = Jump (if) Not Zero
    ; JNZ is a conditional jump instruction that checks Zero Flag (ZF) register.
    ; `DEC CL` sets ZF=1 if result is 0; ZF=0 otherwise.
    ; `JNZ` jumps only if ZF=0 (i.e., CL != 0).
    ; If ZF=0 -> jump to the `write_loop` label -> loop behaviour is achieved.
    ; When ZF=1 do not jump and keep going to the next instruction (below).

    mov byte [rdi], 0xA  ; [buffer + N] = '\n' (0xA)

    ; print all
    mov rax, sys_write
    mov rdi, stdout_fd  ; RDI reused: previous value (buffer ptr) is no longer needed
    mov rsi, buffer  ; now the buffer (the start of its memory region) is the source
    mov rdx, BUFFER_SIZE
    syscall

    ; quit
    mov rax, sys_exit
    mov rdi, sys_exit_success
    syscall
