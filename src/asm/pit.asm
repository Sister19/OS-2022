
global _setPIT

; _setPIT:
;     push ax
; Channel 0 / lohibyte / hardware re-triggerable one-shot / 16 bit
; mov ax, 0b00_11_010_0
; out 0x40, ax
;     pop ax
;     ret

extern _printString
count: dw 0x6000

timer_frac: dw 0x1
timer_ms:   dw 0x1

_setPIT:
    cli
    call makeInterrupt8
    pushad
    pushfd
    mov bx, 0xFFFF

    mov al, 0b00_11_010_0
    out 0x43, al

    mov ax, 0xFFFF
    out 0x40, al
    mov al, ah
    out 0x40, al

    popfd
    popad
    sti
    ret


makeInterrupt8:
	;get the address of the service routine
	mov dx,irqhandler
	push ds
	mov ax, 0	;interrupts are in lowest memory
	mov ds,ax
	mov si,0x20	;interrupt 0x21 vector (21 * 4 = 84)
	mov ax,cs	;have interrupt go to the current segment
	mov [si+2],ax
	mov [si],dx	;set up our vector
	pop ds
	ret



irqhandler:
    push ax
    push bx

    mov ax, 1
    mov bx, 1
    add [timer_frac], ax
    adc [timer_ms], ax

    mov al, 0x20
    out 0x20, al

    ; mov

    pop bx
    pop ax
    iret

global _sleep
_sleep:
    push bp
    mov bp, sp
    push ax
    mov ax, 0x100
    mov [count], ax
loop:
    cli
    mov ax, [count]
    xor ax, ax
    jz sdone
    sti
    nop
    nop
    nop
    nop
    nop
    jmp loop
sdone:
    sti
    pop ax
    pop bp
    ret

global TimerIRQ
TimerIRQ:
    push ax
    mov ax, [count]
    xor eax, eax
    jz done
    mov ax, [count]
    dec ax
    mov [count], ax
done:
    pop ax
    ret
