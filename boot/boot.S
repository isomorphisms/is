.code16
.section .text
.global _start

_start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %ss
    movw $0x7c00, %sp
    sti

    call serial_init
    movw $message, %si

print_loop:
    lodsb
    testb %al, %al
    jz halt
    call serial_write
    jmp print_loop

halt:
    hlt
    jmp halt

serial_init:
    movw $0x3f9, %dx
    movb $0x00, %al
    outb %al, %dx

    movw $0x3fb, %dx
    movb $0x80, %al
    outb %al, %dx

    movw $0x3f8, %dx
    movb $0x01, %al
    outb %al, %dx

    movw $0x3f9, %dx
    movb $0x00, %al
    outb %al, %dx

    movw $0x3fb, %dx
    movb $0x03, %al
    outb %al, %dx

    movw $0x3fa, %dx
    movb $0xc7, %al
    outb %al, %dx

    movw $0x3fc, %dx
    movb $0x0b, %al
    outb %al, %dx
    ret

serial_write:
    movb %al, %ah

wait_tx:
    movw $0x3fd, %dx
    inb %dx, %al
    testb $0x20, %al
    jz wait_tx

    movw $0x3f8, %dx
    movb %ah, %al
    outb %al, %dx
    ret

message:
    .asciz "IS_BOOT_OK\r\n"
