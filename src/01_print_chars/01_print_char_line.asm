; The "01_print_char_line.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program prints a line of character with a new line char.
; Here loops are introduced and flag registers are covered.
;
; A CPU has flag, or status, registers (RFLAGS for x64 and EFLAGS for "x32").
; Some (but not all) commonly used flags are:
; - auxiliary carry flag (AF) -> overflow for binary-coded decimal (BCD) arithmetic;
; - carry flag (CF) -> unsigned (!) overflow (0xFF + 1 = 0x100 -> carry out);
; - overflow flag (OF) -> signed (!) overflow (127 + 1 = -128 -> OF=1);
; - parity flag (PF) -> the number of 1s in the low byte (if even, then PF=1, see notes below);
; - sign flag (SF) -> equals the most significant bit (MSB) of the result (SF=1 -> negative);
; - zero flag (ZF) -> the result is 0 (1 - 1 = 0 -> ZF=1);
;
; New instructions in this program:
; - INC -> increment (add 1):
;   - syntax: `inc destination` - a register or a memory location;
;   - means `destination = destination + 1`;
;   - unary arithmetic instruction;
;   - no immediate value is allowed;
;   - affects flags:
;     - updates SF, ZF, PF, OF, AF;
;     - does not update CF;
; - DEC -> decrement (subtract 1):
;   - syntax: `dec destination` - a register or a memory location;
;   - means `destination = destination - 1`;
;   - unary arithmetic instruction;
;   - no immediate value is allowed;
;   - affects flags:
;     - updates SF, ZF, PF, OF, AF;
;     - does not update CF;
; - TEST -> bitwise AND:
;   - syntax: `test operand1, operand2`;
;   - does not save the result, but updates (R/E)FLAGS:
;     - ZF=1 if the result is 0 (a AND b == 0);
;     - SF=1 if the MSB of the result is 1;
;     - PF=1 if the total count of 1s in a low byte is even;
;     - CF and OF are cleared (set to 0);
; - JZ -> "Jump if Zero" -> branches to a label if ZF=1:
;   - syntax: `jz label`;
;   - if ZF=1, then `jz label` jumps to the `label`;
; - JNZ -> "Jump if Not Zero" -> branches to a label if ZF=0:
;   - syntax: `jnz label`;
;   - if ZF=0, then `jnz label` jumps to the `label`;
;   - opposite to the `JZ` instruction;
;
; Notes
;
; MOV instruction
; ---------------
; The MOV instruction does not update FLAGS.
;
; Parity
; ------
; Concerning integers, the parity means their oddness or evenness.
; For instance, 3 (0b0000_0011) is odd and 4 (0b0000_0100) is even.
; If the least significant bit (LSB) is 1, then odd, else even.
;
; Parity means "is the total number of 1 bits in one (!) byte even or odd?”"
; Even parity = total count of 1 is even, otherwise, odd parity.
; Examples:
; * 135 = 0b1000_0111 -> the number is odd (LSB is 1), the parity is odd (three 1s in the low byte);
; * 134 = 0b1000_0110 -> the number is even (LSB is 0), the parity is even (two 1s in the low byte);
; * 3 = 0b0000_0011 -> the number is ODD, but the parity is EVEN (two 1s in the low byte);
; * 4 = 0b0000_0100 -> the number is EVEN, but the parity is ODD (only one 1 in the low byte)
;
; In short, don't confuse LSB with parity...though they are confusing.
;
; Parity checking was a simple hardware-efficient error-detection mechanism.
; It emerged in the early days of digital computing and telecom,
; when data transmission was prone to errors (noise, interference, mech issues etc.).
; A single bit flip could corrupt data, that is why parity bits were added to detect such errors.
;
; Today, parity checking is fallen out of use because of:
; * better error-detection methods;
; * more reliable physical layers etc.
;
; Yet, the PF remains in x86 for backward-compatibility.
;

CHAR equ '*'  ; character to print (actually an ASCII code)
%if CHAR < 0 || CHAR > 255
    %error "char must be a valid ASCII byte (0-255)"
%endif

NCHARS equ 10  ; the number of chars in a line
%if NCHARS < 0 || NCHARS > 255
    %error "the number of chars must be a valid byte (0-255)"
%endif

BUFFER_SIZE equ NCHARS + 1  ; NCHARS chars + 1 newline byte (0xA)
NEWLINE equ 0xA

stdout_fd equ 1        ; stdout (file descriptor 1)
sys_write equ 1        ; write syscall
sys_exit equ  60       ; exit syscall
sys_exit_success equ 0 ; success return code


section .bss
    buffer: resb BUFFER_SIZE

section .text
    global _start

_start:
    mov cl, NCHARS   ; initialise loop counter (NCHARS may be 0)
    test cl, cl  ; test if CL is 0 (0 and 0 is 0, so ZF=1, otherwise ZF=0)
    jz .quit  ; if ZF=1, just quit by jumping to the .quit label
    mov rdi, buffer  ; buffer is a destination

; The following section is "within" the _start label context,
; so is the following `.write_loop` label
; which is a local label belonging to the preceding global label (`_start`).
; This has nothing to do with label scopes or nesting, it is all linear.
.write_loop:
    mov byte [rdi], CHAR  ; write CHAR at the RDI (=buffer here) address -> dereferencing
    inc rdi  ; increment RDI -> moves pointer forward (the next address -> no dereferencing)
    dec cl   ; decrement counter -> sets ZF=1 if result is 0
    jnz .write_loop  ; ZF=1 -> `DEC CL` has not set ZF to 0 -> jump back and repeat -> loop!
    mov byte [rdi], NEWLINE  ; [buffer + N] = '\n' (0xA)

    ; print all
    mov rax, sys_write
    mov rdi, stdout_fd  ; RDI reused: previous value (buffer ptr) is no longer needed
    mov rsi, buffer  ; now the buffer (the start of its memory region) is the source
    mov rdx, BUFFER_SIZE
    syscall

.quit:
    mov rax, sys_exit
    mov rdi, sys_exit_success
    syscall
