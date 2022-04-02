; Tim Asisten Sister 19 - Last modified : April 2022
global _setPIT
global _usleep
extern _contextSwitch
extern _counter

_usleep:
    push bp
    mov bp, sp
    push ax
    push bx
    mov ax, [bp + 4]
    mov [_counter], ax
.loop:
    cli
    mov ax, [_counter]
    or ax, ax
    jz .done
    sti
    nop
    nop
    nop
    nop
    nop
    jmp .loop
.done:
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

    ; Channel 0 / lohibyte / rate generator / 16 bit
    mov al, 0b00_11_010_0
    out 0x43, al

    ; Send frequency value, 1193182 / 0xe90b = ~20 hz
    ; NOTE : Dependent on emulator clock speed and ips
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


; IRQ 0 Handler
IRQ0Handler:
    push ax
    push bx

    call _contextSwitch

    mov al, 1
    mov al, 0x20
    out 0x20, al

    pop bx
    pop ax
    iret
