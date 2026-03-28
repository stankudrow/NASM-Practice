; The "putchar.asm" [NASM 2.16.01] program for x64 Linux/BSD.
;
; This program prints a character with a newline '\n' digraph.
;
; Here the lower parts of of some registers will be used.
; For instance, consider the RAX (R=register) register for x64.
; Since it is 64-bit version, it has [63, 62, ..., 1, 0] bits (64 in total).
; Its [31, ..., 0] component is the EAX (E=extended) version for x86_32.
; The [15, ..., 0] segment is the AX 16-bit version.
; AX (X = extended for 16-bit version) consists of two parts:
; - AH (high) = [15, ..., 8] bits;
; - AL (low) = [7, ..., 0] bits.
; So, RAX > EAX > AX (=AH <+> AL), where <+> means "join" or "concatenation".
; If only 1 byte matters, then AL or even AH will do,
; but caution code operates with (R|E)AX variants,
; becuase working with AL or AH does not zero E/R parts of the register,
; so using EAX or RAX may lead to unexpected results because of rubbish data.
;
; The registers covered here:
; - RDX (Data) -> general-purpose register for:
;   - data movement, arithmetic, logic etc.;
;   - I/O port addressing;
;   - high half of 64‑bit multiplication/division:
;     - multiplication -> high 64 bits of the 64x64 product (128-bit result);
;     - division -> remainder (64-bit)
;   - RDX > EDX > DX (DH <+> DL), where <+> is concatenation/join;
; - RSI (Source Index) -> source data address (mostly string/memory ops).
;   - RSI > ESI > SI
;
; In this script label dereferencing is in use.
; Suppose we have a `my_label` that is associated with a memory address.
; Referring to it as `my_label` means dealing with the address.
; If in brackets, i.e. `[my_label]`, then working with the data fetched from the `my_label` address.
; Examples:
; `mov rbx, label` -> rbx holds the address of the label.
; `mov rbx, [label]` -> rbx stores the value fetched from the `label` address.
;
; A label with a colon (`:`) after it defines a code/data label.
; Such labels (symbols) can be (de)referenced.
;
; A CPU has falgs (also called "status flags" or "condition" codes),
; which are a set of single-bit (!) indicators in the CPU's flags register (R- or E- or just FLAGS).
; Most common flags to know for daily use in Assembly programming:
; - carry flag (CF) -> unsigned overflow (for an unsigned byte, `255 + 1 = 0` -> CF=1);
; - auxiliary carry flag (AF) -> binary-coded decimal arithmetic overflow (carry from bit 3 to bit 4);
; - zero flag (ZF) -> if the result of an operation is exactly 0 (`1 - 1 = 0` -> ZF=1);
; - sign flag (SF) -> equal to the most significant bit (MSB) (`127 + 1 = -128` -> 0b1000_0000 -> SF=1);
; - overflow flag (OF) -> signed overflow (`127 + 1 = -128` -> OF=1);
; - parity flag (PF) -> the umber of 1‑bits in the low byte of the result is even (3 = 0b0000_0011 -> PF=1, yet 3 is odd).
;
; The FLAGS are important for understanding the following new instructions:
; - CMP -> CoMPare:
;   - syntax: `cmp operand1, operand2`;
;   - computes `operand1 - operand2`;
;   - leaves operands unmodified, the result is discarded;
;   - updates the flags: ZF, SF, OF, CF
; - JL -> Jump if Less (signed comparison):
;   - syntax: `jl label`
;   - jump if the result of the exactly previous, e.g., `cmp opr1, opr2' instruction reveals that `opr1 < opr2`;
;   - jump if SF != OF:
;     - SF=OF=0 => `opr1 >= opr2` (e.g., `cmp 127, 127` -> 127 - 127 = 0 -> fits) -> NO JUMP;
;     - SF=OF=1 => `opr1 >= opr2` (e.g., `cmp 127, -1` -> 127 - (-1) = -128) -> NO JUMP;
;     - SF=0, OF=1 => `opr1 < opr2` (e.g., `cmp -128, 127` -> -128 - 127 = 127 - 126 = 1) -> JUMP;
;     - SF=1, OF=0 => `opr1 < opr2` (e.g., `cmp -1, 127` -> -1 - 127 = -128 -> fits) -> JUMP.
;
; Note. MOV does not update FLAGS.
;


; (symbolic) constants for "business" logic
CHAR equ '*'       ; 1-character string -> ASCII code because 1 character
; Preprocessor directives are handy here because:
; - they are compile-time checks,
; - zero (!) runtime overhead -> no need to run and then check.
; Preprocessor directives start with a percent `%` character.
%if CHAR < 0 || CHAR > 255  ; || means the OR operator
    %error "char must be a valid ASCII byte (0-255)"
%endif
NEWLINE equ 0xA  ; avoid temptation to define ot as '\n' -> 2-characters string!
BUFFER_SIZE equ 2  ; buffer size: CHAR + '\n'
; (symbolic) constants for system calls
stdout_fd equ 1         ; stdout (file descriptor 1)
sys_write equ 1         ; "write(fd, buf, siz)" syscall
sys_exit equ  60        ; "exit(retcode)" syscall
sys_exit_success equ 0  ; success return code
sys_exit_failure equ 1  ; in case something goes wrong


section .bss
    buffer: resb BUFFER_SIZE
    ; `res`erve 2 `b`ytes for the region associated with the buffer label

section .text
    global _start

_start:
    mov al, CHAR  ; al = 8 bits, so an ASCII char will fit!
    mov [buffer], al  ; [buffer] == buffer[0] -> buffer[0] = al (=CHAR)
    mov byte [buffer + 1], NEWLINE  ; [buffer + 1] == buffer[1] == buffer (start) + 1 byte shift
    ; Here, byte (after the MOV) is crucial,
    ; otherwise: "error: operation size not specified".
    ; For the `mov [buffer], al` the byte specifier is redundant,
    ; because NASM "understands" that AL is a 1-byte register already.
    ; In case of `buffer`, there is no inherit size, so clarity is enforced.

    ; --- `write(fd, buffer, size)` syscall ---
    ; ABI (Application binary interface) for `write(fd, buffer, size)` system call:
    ; - RAX -> system call integer code (1 = write);
    ; - RDI -> the first argument is a file descriptor;
    ; - RSI -> the second argument is a source memory region;
    ; - RDX -> the third argument is the number of bytes to write starting from the address in the RSI.
    ; Also, possible error code values (negative integers) are stored in the RAX after `syscall` invocation.

    mov rax, sys_write    ; 999 -> errno -38 (ENOSYS - function not implemented)
    mov rdi, stdout_fd    ; 999 -> errno -9 (EBADF - bad file descriptor)
    mov rsi, buffer       ; 0xabcdef (arbitrary address) -> errno -14 (EFAULT -> bad address)
    mov rdx, BUFFER_SIZE  ; -1 -> -14 (checked with gdb)
    syscall

    ; check `write` status
    cmp rax, 0  ; compare RAX with 0 -> will set some flags
    ; then `JL` will scheck flags and either jumps or the flow continues normally
    jl .error   ; if RAX is Less than 0, then Jump to the .error label

    ; exit the program
    mov rax, sys_exit
    mov rdi, sys_exit_success
    syscall
    ; after this `exit(0)` system call the execution stops

.error:
    mov rax, sys_exit
    mov rdi, sys_exit_failure
    syscall
