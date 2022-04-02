
global _setPIT

; _setPIT:
;     push ax
; Channel 0 / lohibyte / hardware re-triggerable one-shot / 16 bit
; mov ax, 0b00_11_010_0
; out 0x40, ax
;     pop ax
;     ret

extern _printString
count: dw 0x1

timer_frac: dw 0x1
timer_ms:   dw 0x1

_setPIT:
    call makeInterrupt8
    pushad
    pushfd

    ; Channel 0 / lohibyte / hardware re-triggerable one-shot / 16 bit
    mov al, 0b00_11_010_0
    out 0x43, al

    ; Send frequency value, 3579545 / 0xE90B = 60.00 hz < not this
    ; Send frequency value, 1193182 / 0xFFFF = 18.20 hz < this
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



IRQ0Handler:
    push ax
    push bx
    ; call _printString
    ; mov ax, 1
    ; mov bx, 1
    ; add [timer_frac], ax
    ; adc [timer_ms], ax
    call TimerIRQ

    mov al, 0x20
    out 0x20, al

    pop bx
    pop ax
    iret

global _sleep
_sleep:
    push bp
    mov bp, sp
    push ax
    mov ax, 225
    mov [count], ax
loop:
    cli
    mov ax, [count]
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
    pop ax
    pop bp
    ret

; global TimerIRQ
; memory storing problem too, use data
TimerIRQ:
    push ax
    mov ax, [count]
    or ax, ax
    jz .tdone
    mov ax, [count]
    dec ax
    mov [count], ax
.tdone:
    pop ax
    ret
