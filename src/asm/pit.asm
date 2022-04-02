; Tim Asisten Sister 19 - Last modified : April 2022
global _setPIT
global _sleep

countdown: dw 0x1

_sleep:
    push bp
    mov bp, sp
    push ax
    push bx
    mov ax, [bp + 4]
    mov bx, 225
    mul bx
    mov [countdown], ax
loop:
    cli
    mov ax, [countdown]
    or ax, ax
    jz done
    sti
    nop
    nop
    nop
    nop
    nop
    jmp loop
done:
    sti
    pop bx
    pop ax
    pop bp
    ret

_setPIT:
    call makeInterrupt8
    cli
    pushad
    pushfd

    ; Channel 0 / lohibyte / hardware re-triggerable one-shot / 16 bit
    mov al, 0b00_11_010_0
    out 0x43, al

    ; Send frequency value, 1193182 / 0xe90b = 20 hz
    ; FIXME : For some reason 0xe90b = ~225 hz
    mov ax, 0xE90B
    out 0x40, al
    mov al, ah
    out 0x40, al

    popfd
    popad
    ret

makeInterrupt8:
	mov dx, IRQ0Handler
	push ds
	mov ax, 0
	mov ds, ax
	mov si, 0x20
	mov ax, cs
	mov [si+2], ax
	mov [si], dx
	pop ds
	ret


; Interrupt handler, decrement global variable count, if zero call function
IRQ0Handler:
    push ax
    push bx

    call TimerIRQ

    mov al, 1
    mov al, 0x20
    out 0x20, al

    pop bx
    pop ax
    iret

TimerIRQ:
    push ax
    mov ax, [countdown]
    or ax, ax
    jnz .tdone

    jmp .tret
.tdone:
    mov ax, [countdown]
    dec ax
    mov [countdown], ax
.tret:
    pop ax
    ret
